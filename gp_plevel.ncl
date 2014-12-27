; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
; Created: Thursday, July 11 2013
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>

import("yagUtils")

begin
  a = set_inputfile()
  lev = 500
  t = 95
  out  = "geo_p" + lev       ;out put file name
  type = "pdf"

  wks = gsn_open_wks(type,out)
  gsn_reverse_colormap(wks)

  p  = wrf_user_getvar(a,"pressure",t)
  gp_1 = wrf_user_getvar(a,"geopt",t)

  gp = wrf_user_intrp3d(gp_1,p,"h",lev,0.,False)

  res = True
  set_res_cn_limits(res,48900,49600,30)
  res =  set_res_cn(res)
  plot = wrf_contour(a,wks,gp,res)
  opts  = set_res_highres_coast(True)
  map = wrf_map_overlays(a,wks,plot,True,opts)

end
