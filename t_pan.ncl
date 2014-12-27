import("yagUtils")

begin
  a = set_inputfile()

  tvalues = (/19, 22, 25, 28, 32, 35 /)
  type = "pdf"

  vname = "t"
  angle = 0.

; IMPORTANT comment out for "t2" plotting.
  lev = 500

  if ( isdefined("lev") ) then
    out = vname + lev +"hpa" + "_pan"
  else
    out = "t2" + "_pan"
  end if

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"BlGrYeOrReVi200")

  times  = wrf_user_list_times(a)  ; get times in the file
  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  res = True
  res = set_res_no_frame(res)
  res = set_res_lb(res)
  res = set_res_tm_size(res)
  res = set_res_highres_coast(res)
  res = set_aspectratio(xlat,res)
  res@mpGeophysicalLineThicknessF = 3
  res@gsnMajorLatSpacing = 1
  res@gsnMajorLonSpacing = 1

  res@cnFillOn = True
  res@cnLinesOn = False
  res@lbLabelBarOn = False
  res@gsnLeftString = ""
  res@gsnRightString = ""
  res = set_res_mp_latlon(res,141.,145,43,47.5)

;   if ( isdefined("lev") ) then
;     set_res_cn_limits(res,-30.,0.,.1)
; ;    set_res_cn_limits(res,-14.,0.,.5)
;   else
;     set_res_cn_limits(res,250.,280.,1)
;   end if

  do it = 0, noft - 1, 1
    vt = tvalues(it)
    print("working with: "+ vt + " "+ times(vt))
    p  = wrf_user_getvar(a,"pressure",vt)
    T =  wrf_user_getvar(a,"tc",vt)
    t = wrf_user_intrp3d(T,p,"h",lev,angle,False)
;    t = wrf_user_getvar(a,"TSK",vt)
;    t = wrf_user_getvar(a,"T2",vt)

    t@lat2d = xlat
    t@lon2d = xlon

    res@gsnLeftString = times(vt)
    plot(it) = gsn_csm_contour_map(wks,t,res)
  end do

  pres = set_res_panel(True)
  pres@lbLabelStride = 6
  panelize_2col(wks,plot,pres)

end
;;; t_pan.ncl ends here
