load "$nsc/yagUtils.ncl"

begin
  a = set_inputfile()
  coard = (/265,336,126,223/)
  wks = gsn_open_wks("ps","barb")
  gsn_define_colormap(wks,"WhBlGrYeRe")
  g = 9.8                       ; gravity

  times = wrf_user_list_times(a)
  tlen = dim_len0(times)

  dims = filevardimsizes(a,"QSNOW")
  q = new((/tlen,dims(1)/),float)
  q_wgt = new(tlen,float)
  u_mean = new((/tlen,dims(1)/),float)
  v_mean = new((/tlen,dims(1)/),float)
  noflevels=25

  ofname = "prof.nc"
  system("rm -f " + ofname)
  o =  addfile(ofname, "c")
  filedimdef(o,"Time", -1,True)

  do it = 0, tlen - 1 , 1   ;; tloop
    print("Working with: " + it)
    u = a->U(it,:,:,:)
    u_a = u(:,265:336,126:223)
    delete(u)
    u_area = dim_avg_n_Wrap(u_a,(/1,2/))
    delete(u_a)
    u_mean(it,:) = u_area

    v = a->V(it,:,:,:)
    v_a = v(:,265:336,126:223)
    delete(v)
    v_area = dim_avg_n_Wrap(v_a,(/1,2/))
    delete(v_a)
    v_mean(it,:) = v_area

    qs = a->QSNOW(it,:,:,:)
    qs_a = qs(:,265:336,126:223)
    delete(qs)
    qs_area = dim_avg_n_Wrap(qs_a,(/1,2/))

    qc = a->QCLOUD(it,:,:,:)
    qc_a = qc(:,265:336,126:223)
    delete(qc)
    qc_area = dim_avg_n_Wrap(qc_a,(/1,2/))

    q(it,:) = qs_area + qc_area
    delete(qs_area)
    delete(qc_area)


    ; weighted sum of q
    gh = wrf_user_getvar(a,"z",it)
    gh_a = gh(:,265:336,126:223)
    delete(gh)
    gh_area = dim_avg_n_Wrap(gh_a,(/1,2/))

    p = wrf_user_getvar(a,"z",it)
    p_a = p(:,265:336,126:223)
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
