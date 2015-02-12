import("yag_utils")

begin
  a = set_inputfile()

  ; specify desired timestep outputs must be even
  tvalues = (/ 73,83,90,101 /)

  type = "pdf"
  out = "t_qs_pan"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"BlGrYeOrReVi200")

  temp_overlay = True
  varname = "QSNOW"

  angle = 0.
  lev = 940

  times  = wrf_user_list_times(a)  ; get times in the file
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
  res@mpGeophysicalLineThicknessF = 3
  res@gsnMajorLatSpacing = 1
  res@gsnMajorLonSpacing = 1
  res = set_res_mp_latlon(res,141.,145,43,47.5)
  set_res_cn_limits(res,260.,280.,.5)

  opts = True
  opts = set_res_cn_lines(opts)
  opts = set_res_no_frame(opts)
  opts = set_res_tm_size(opts)
  opts = set_res_lb(opts)
  opts = set_res_tm_size(opts)
  set_res_cn_limits(opts, 1,10,1)

  do it = 0, noft - 1, 1
    vt = tvalues(it)
    print("working with: "+ vt + " ,"+ times(vt))

    p  = wrf_user_getvar(a,"pressure",vt)
;    t2 =  wrf_user_getvar(a,"tc",vt)
    t2 = wrf_user_getvar(a,"T2",vt)

    t2@lat2d = xlat
    t2@lon2d = xlon

    wgted_var = wrf_user_getvar_weighted_sum(a,varname,vt)

    wgted_var@lat2d = xlat
    wgted_var@lon2d = xlon

    if ( temp_overlay ) then
      res@gsnLeftString = times(vt)
      res@cnFillOn = True
      plot(it) = gsn_csm_contour_map_overlay(wks,t2,wgted_var,res,opts)
    else
      opts@gsnLeftString = times(vt)
      plot(it) = gsn_csm_contour_map(wks,wgted_var,opts)
    end if
  end do

  pres = set_res_panel(True)
  pres@lbLabelStride = 6
  panelize_2col(wks,plot,pres)
end
;;; t2_qs_pan.ncl ends here
