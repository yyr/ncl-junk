import("yag_utils")

begin
  f1 = "/home/yagnesh/WRFMPI/WRFV3/test/bd/res/wrfout_d03_2008-12-25_00:00:00"
  f2 ="/home/yagnesh/WRFMPI/WRFV3/test/bd_no_sak/d3/wrfout_d03_2008-12-25_00:00:00"
  a = addfile(f1,"r")
  b = addfile(f2,"r")

  vt = 95
  type = "pdf"
  out = "diff_t2" + "_" + vt

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"hotcolr_19lev")

  times  = wrf_user_list_times(a)  ; get times in the file
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
  res@gsnLeftString = ""
  res@gsnRightString = ""
  res = set_res_mp_latlon(res,141.,145,43,47.5)
  set_res_cn_limits(res,-10.,10.,.5)

  print("working with: "+ vt + " "+ times(vt))

  ; T =  wrf_user_getvar(a,"tc",vt)
  t2 = wrf_user_getvar(a,"T2",vt)
  t2_2 = wrf_user_getvar(b,"T2",vt)

  t = t2_2 - t2

  t@lat2d = xlat
  t@lon2d = xlon

  plot = gsn_csm_contour_map(wks,t,res)
end
;;; t2_qs_pan.ncl ends here
