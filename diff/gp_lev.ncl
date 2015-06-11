; Created: Friday, July 12 2013

import("yag_utils")
begin
  a = set_inputfile()
  lev1 = 850
  lev2 = 1000

  var = "geopt"
  vt = 85
  out  = "diff_" + var + "_" + lev1 + "--" + lev2       ;out put file name
  type = "pdf"

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
  res@gsnLeftString = "diff " + var + "(" + lev1 + "-" + lev2 + ")"

  print("working with: "+ vt + " "+ times(vt))
  ; set_res_cn_limits(res,8200,8600,20)

  p  = wrf_user_getvar(a,"pressure",vt)
  gp_1 = wrf_user_getvar(a,"geopt",vt)

  gp1 = wrf_user_intrp3d(gp_1,p,"h",lev1,0.,False)
  gp2 = wrf_user_intrp3d(gp_1,p,"h",lev2,0.,False)

  gp = gp1 - gp2
  gp@units = gp1@units

  gp@lat2d = xlat
  gp@lon2d = xlon

  printVarInfo(gp,"")
  plot = gsn_csm_contour_map(wks,gp,res)
end
