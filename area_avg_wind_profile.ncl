load "$nsc/yagUtils.ncl"

begin
  a = set_inputfile()
  ; coard = (/265,336,126,223/)
  coard = (/92,218,213,372/)
  lo = coard(0)                      ; left lon
  ro = coard(1)                      ; right lon
  la = coard(2)                       ; left lat
  ra = coard(3)                      ; right lat

  g = 9.8                       ; gravity

  times = wrf_user_list_times(a)
  tlen = dim_len0(times)

  dims = filevardimsizes(a,"QSNOW")
  q = new((/dims(0),dims(2),dims(3)/),float) ;time,lat,lon
  u_mean = new((/tlen,dims(1)/),float)
  v_mean = new((/tlen,dims(1)/),float)
  noflevels=14

  ofname = "prof.nc"
  system("rm -f " + ofname)
  o =  addfile(ofname, "c")
  filedimdef(o,"Time", -1,True)

  do it = 0, tlen - 1 , 1   ;; tloop
    print("Working with: " + it)
    u = a->U(it,:,:,:)
    u_a = u(:,lo:ro,la:ra)

    delete(u)
    u_area = dim_avg_n_Wrap(u_a,(/1,2/))
    delete(u_a)
    u_mean(it,:) = u_area

    xland = a->XLAND(it,:,:)
    b = where(xland .eq. 1 , 0 , 1)
    b_a = b(lo:ro,la:ra)
    delete(xland)
    delete(b)

    v = a->V(it,:,:,:)
    v_a = v(:,lo:ro,la:ra)
    delete(v)
    v_area = dim_avg_n_Wrap(v_a,(/1,2/))
    delete(v_a)
    v_mean(it,:) = v_area

    q(it,:,:) = wrf_user_getvar_weighted_sum(a, (/"QSNOW", "QCLOUD", "QRAIN", "QICE"/), it)
  end do

  o->q = q(:,lo:ro,la:ra)
  o->u_mean = u_mean
  o->v_mean = v_mean
  o->T2 = a->T2

end
