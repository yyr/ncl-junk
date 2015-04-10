import("yag_utils")

begin
  a = set_inputfile()

  ; specify desired timestep outputs must be even
  tvalues = (/ 60, 70, 82, 95, 102, 114, 126, 143/)

  type = "pdf"
  out = "t_qs_pan"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"BlGrYeOrReVi200")

  temp_overlay = True
  varname = "QSNOW"

  angle = 0.
  lev = 940

  times = a->Times
  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  res = True
  res = set_res_cn(res)
  res = set_res_no_frame(res)
  res = set_res_lb(res)
  res = set_res_tm_size(res)
  res = set_res_highres_coast(res)
  res@lbLabelBarOn = False
  res@gsnMajorLatSpacing = 1
  res@gsnMajorLonSpacing = 1
  res = set_res_mp_latlon(res,141.,145,43,47.5)
  set_res_cn_limits(res,260.,280.,.5)

  opts = True
  opts = set_res_cn_lines(opts)
  opts = set_res_no_frame(opts)
  opts = set_res_lb(opts)
  set_res_cn_limits(opts, 2,20,2)

  do it = 0, noft - 1, 1
    vt = tvalues(it)
    print("tvalue: " + tvalues(it))

    p  = wrf_user_getvar(a,"pressure",vt)
    T =  wrf_user_getvar(a,"tc",vt)
    t = wrf_user_intrp3d(T,p,"h",lev,angle,False)
    t = t + 273.14
    t@long_name = "T at " + lev ; + "hPa"
    t@units = "K"
    ; t = wrf_user_getvar(a,"T2",vt)

    t@lat2d = xlat
    t@lon2d = xlon

    wgted_var = wrf_user_getvar_weighted_sum(a,varname,vt)
    wgted_var@lat2d = xlat
    wgted_var@lon2d = xlon

    date_string = chartostring(times(vt,5:15))
    if ( temp_overlay ) then
      res@gsnCenterString = date_string
      res@cnFillOn = True
      plot(it) = gsn_csm_contour_map_overlay(wks,t,wgted_var,res,opts)
    else
      opts@gsnCenterString = date_string
      opts = set_res_tm_size(opts)
      plot(it) = gsn_csm_contour_map(wks,wgted_var,opts)
    end if
  end do

  pres = set_res_panel(True)
;  pres@lbOrientation = "horizontal"
  pres@lbLabelStride = 6
  panelize_2col(wks,plot,pres)
end
;;; t2_qs_pan.ncl ends here
