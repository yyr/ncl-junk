import("yag_utils")
begin
  a = set_inputfile()
  tvalues = (/ 60,80,100,120 /)

  out = "slp_gh_pan"       ;out put file name
  type = "pdf"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
  times = a->Times
  noft = dim_len0(tvalues)
  plot = new(noft,graphic)
  lev = 500

  res = True
  res = set_res_cn(res)
  res = set_res_no_frame(res)
  res = set_res_highres_coast(res)
  res = set_res_tm_size(res)
  res@tfDoNDCOverlay = True

  set_res_cn_limits(res, 970, 1030,1)
  false(res,"lbLabelBarOn")

  res_gh = True
  res_gh = set_res_cn_lines(res_gh)
  res_gh@tfDoNDCOverlay = True
  res_gh@lbTitleOn = False
  ; set_res_cn_limits(res_gh, 48200, 50300 ,150)

  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  do it = 0, noft - 1, 1   ; LOOP NAME
    vt = tvalues(it)
    print("tvalue: " + tvalues(it))
    slp = wrf_user_getvar(a,"slp",tvalues(it))
    slp@long_name = "slp"

    p  = wrf_user_getvar(a,"pressure",tvalues(it))
    gh = wrf_user_getvar(a,"geopt",tvalues(it))
    gh_lev = wrf_user_intrp3d(gh, p,"h",lev,0.,False)
    gh_lev@lat2d = xlat
    gh_lev@lon2d = xlon

    res = wrf_map_resources(a,res)
    res = set_lb_resources(slp,res)
    date_string = chartostring(times(vt,5:15))
    res@gsnCenterString = date_string
    res@gsnLeftString = "slp"
    delete_attrs(res)

    res_gh = True
    res_gh = set_res_cn_lines(res_gh)
    res_gh@cnInfoLabelOn = True

    set_res_cn_limits(res_gh, 48200, 50300, 100)
    res_gh@cnInfoLabelOrthogonalPosF = 0.015
    ; plot(it) = gsn_csm_contour_map(wks,gh_lev,res)
    plot(it) =gsn_csm_contour_map_overlay(wks,slp,gh_lev,res,res_gh)
  end do

  pres = set_res_panel(True)
  pres@lbLabelStride  = 6
  ; pres@txString         = "Geo-potential Height and Sea Level Pressure"
  panelize_2col(wks,plot,pres)
end
