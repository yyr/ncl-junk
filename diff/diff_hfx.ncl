import("yag_utils")

begin
  f1 = "/home/yagnesh/WRFMPI/WRFV3/test/bd/res/wrfout_d03_2008-12-25_00:00:00"
  f2 ="/home/yagnesh/WRFMPI/WRFV3/test/bd_no_sak/d3/wrfout_d03_2008-12-25_00:00:00"
  a = addfile(f1,"r")
  b = addfile(f2,"r")

  vt = 85
  type = "pdf"
  out = "diff_hfx" + "_" + vt
  var = "HFX"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"BlueRed")

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
  res = set_res_mp_latlon(res,141.,145,43,47.5)

  res@cnFillOn = True
  res@cnLinesOn = False
  res@gsnLeftString = "diff HFX"

  ; set_res_cn_limits(res,-100,700.,40)
  print("working with: "+ vt + " "+ times(vt))

  h1 = wrf_user_getvar(a,var,vt)
  h2 = wrf_user_getvar(b,var,vt)

  h = h2 - h1
  h@units = h1@units

  h@lat2d = xlat
  h@lon2d = xlon

  plot = gsn_csm_contour_map(wks,h,res)
end
;;; t2_qs_pan.ncl ends here
