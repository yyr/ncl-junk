import("yag_utils")

begin
  a = set_inputfile()

  type = "pdf"
  out = "t2"
  wks = gsn_open_wks(type,out)
  ; gsn_define_colormap(wks,"BlGrYeOrReVi200")

  times  = wrf_user_list_times(a)  ; get times in the file
  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  res = True
  res = set_res_lb(res)
  res = set_res_highres_coast(res)
  res = set_aspectratio(xlat,res)
  res@mpGeophysicalLineThicknessF = 3
  res@gsnMajorLatSpacing = 1
  res@gsnMajorLonSpacing = 1

  res@cnFillOn = True
  res@cnLinesOn = False
  ; res@gsnLeftString = ""
  ; res@gsnRightString = ""
  res = set_res_mp_latlon(res,141.,145,43,47.5)
  set_res_cn_limits(res,250.,280.,1)

  vt = 95
  print("working with: "+ vt + " "+ times(vt))

  ; T =  wrf_user_getvar(a,"tc",vt)
  t2 = wrf_user_getvar(a,"T2",vt)

  t2@lat2d = xlat
  t2@lon2d = xlon

  plot = gsn_csm_contour_map(wks,t2,res)
end
;;; t2_qs_pan.ncl ends here
