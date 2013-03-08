load "$nsc/yagUtils.ncl"

begin
  a = set_inputfile()
  ; coard = (/265,336,126,223/)
  coard = (/213,372,92,218/)
  lo = coard(0)                      ; left lon
  ro = coard(1)                      ; right lon
  la = coard(2)                       ; left lat
  ra = coard(3)                      ; right lat

  g = 9.8                       ; gravity

  times = wrf_user_list_times(a)
  tlen = dim_len0(times)

  dims = filevardimsizes(a,"QSNOW")
  q = new((/tlen,dims(1)/),float)
  q_wgt = new(tlen,float)
  u_mean = new((/tlen,dims(1)/),float)
  v_mean = new((/tlen,dims(1)/),float)
  noflevels=14

  ofname = "prof_1.nc"
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

    qs = a->QSNOW(it,:,:,:)
    qs_a = qs(:,lo:ro,la:ra)
    delete(qs)
    qs_area = dim_avg_n_Wrap(qs_a,(/1,2/))

    qc = a->QCLOUD(it,:,:,:)
    qc_a = qc(:,lo:ro,la:ra)
    ; qc_a = qc_a * b_a
    delete(qc)
    do ll = 0, dim_len0(qc_a) - 1 , 1    ; doc
      qc_a(ll,:,:) = qc_a(ll,:,:) * b_a
    end do
    qc_area = dim_avg_n_Wrap(qc_a,(/1,2/))

    q(it,:) = qs_area + qc_area
    delete(qs_area)
    delete(qc_area)


    ; weighted sum of q
    gh = wrf_user_getvar(a,"z",it)
    gh_a = gh(:,lo:ro,la:ra)
    delete(gh)
    gh_area = dim_avg_n_Wrap(gh_a,(/1,2/))

    p = wrf_user_getvar(a,"z",it)
    p_a = p(:,lo:ro,la:ra)
    delete(p)
    p_area = dim_avg_n_Wrap(p_a,(/1,2/))

    q_wgted = 0.
    do lev = 0, noflevels, 1   ;; levels
      q_layer = (q(it,lev+1) - q(it,lev)) / 2.
      dgh = gh_area(lev+1) - gh_area(lev) ; 𝑑𝑧
      dp = p_area(lev+1) - p_area(lev) ; 𝑑𝑝
      lay_wgt = -1 * (dp/dgh) / g    ; 𝜚 = - 𝑑𝑝/𝑑𝑧 / 𝑔
      q_lay_wgt = q_layer * lay_wgt

      q_wgted =  q_wgted + q_lay_wgt
    end do

    q_wgt(it) = q_wgted * 1000. ; g/kg instead of kg/kg
  end do
  q@units = "g kg-1"

  ; wspd = (/ sqrt(u_mean^2+v_mean^2) /)
  ; wspd!0 = "Time"
  ; wspd!1 = "bottom_top"

  q!0 = "Time"
  q!1 = "bottom_top"
  u_mean!0 = "Time"
  v_mean!0 = "Time"

  ; q&Time = times
  ; u_mean&Time = times
  ; v_mean&Time = times

  o->q = q
  o->u_mean = u_mean
  o->v_mean = v_mean

end
