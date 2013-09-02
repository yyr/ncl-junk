; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
; Created: Friday, July 12 2013
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>

load "$nsc/yagUtils.ncl"

begin
  a = set_inputfile()
  lev1 = 850
  lev2 = 950

  t = 95
  out  = "gp_diff_" + lev1 + "--" + lev2       ;out put file name
  type = "pdf"

  wks = gsn_open_wks(type,out)
  gsn_reverse_colormap(wks)

  p  = wrf_user_getvar(a,"pressure",t)
  gp_1 = wrf_user_getvar(a,"geopt",t)

  gp1 = wrf_user_intrp3d(gp_1,p,"h",lev1,0.,False)
  gp2 = wrf_user_intrp3d(gp_1,p,"h",lev2,0.,False)

  gp = gp1 - gp2

  res = True
  set_res_cn_limits(res,8200,8600,20)
  res =  set_res_cn(res)
  plot = wrf_contour(a,wks,gp,res)
  opts  = set_res_highres_coast(True)
  map = wrf_map_overlays(a,wks,plot,True,opts)

end
