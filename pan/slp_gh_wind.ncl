import("yag_utils")
begin
  a = set_inputfile()
  tvalues = (/ 73,83,91,101 /)

  out = "slp_gh_wind_pan"       ;out put file name
  type = "pdf"
  wind_overlay = False
  thin = 16

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
  times = a->Times
  noft = dim_len0(tvalues)
  plot = new(noft,graphic)
  lev = 500

  res = True
  res@tfDoNDCOverlay = True
  res@lbTitleOn = False
  res = set_res_cn(res)
  res = set_res_no_frame(res)
  res = set_res_highres_coast(res)
  set_res_cn_limits(res, 970, 1030,1)
  false(res,"lbLabelBarOn")

  res_gh = True
  res_gh = set_res_cn_lines(res)
  res_gh@tfDoNDCOverlay = True
  res_gh@lbTitleOn = False

  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  do it = 0, noft - 1, 1   ; LOOP NAME
    vt = tvalues(it)
    print("tvalue: " + tvalues(it))
    slp = wrf_user_getvar(a,"slp",tvalues(it))

    p  = wrf_user_getvar(a,"pressure",tvalues(it))
    gh = wrf_user_getvar(a,"geopt",tvalues(it))
    gh_lev = wrf_user_intrp3d(gh, p,"h",lev,0.,False)

    res = wrf_map_resources(a,res)
    res = set_lb_resources(slp,res)
    date_string = chartostring(times(vt,5:15))
    res@gsnCenterString = date_string
    delete_attrs(res)

    plot(it) =gsn_csm_contour_map_overlay(wks,slp,gh_lev,res,res_gh)
;    plot(it) =gsn_csm_contour_map(wks,gh_lev,res_gh)

     ; wind overlay
    if ( wind_overlay ) then
      u_1 = wrf_user_getvar(a,"ua",vt)
      v_1 = wrf_user_getvar(a,"va",vt)
      p  = wrf_user_getvar(a,"pressure",vt)
      u = wrf_user_intrp3d(u_1,p,"h",lev,0.,False)
      v = wrf_user_intrp3d(v_1,p,"h",lev,0.,False)

      optsv = True
      optsv@vfXArray = xlon(::thin,::thin)
      optsv@vfYArray = xlat(::thin,::thin)
      optsv@gsnLeftString = ""
      optsv@gsnRightString = ""
      optsv = set_res_vc(optsv)
      optsv@vcLineArrowColor = "white"

      optsv = set_aspectratio(xlat,optsv)
      optsv = set_res_no_frame(optsv)
      vec = gsn_csm_vector(wks,u(::thin,::thin),v(::thin,::thin),optsv)
      overlay(plot(it),vec)
    end if

  end do

  pres = set_res_panel(True)
  pres@lbLabelStride  = 12
  pres@txString         = "sea level pressure"
  panelize_2col(wks,plot,pres)
end
