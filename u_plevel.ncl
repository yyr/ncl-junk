; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
; Created: Friday, July 12 2013
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>

import("yag_utils")

begin
  a = set_inputfile()
  lev = 950
  t = 95
  out  = "u_p" + lev       ;out put file name
  type = "pdf"

  wks = gsn_open_wks(type,out)
;  gsn_reverse_colormap(wks)

  p  = wrf_user_getvar(a,"pressure",t)
  u_1 = wrf_user_getvar(a,"ua",t)

  u = wrf_user_intrp3d(u_1,p,"h",lev,0.,False)

  res = True
  set_res_cn_limits(res,-5,30,1)
  res =  set_res_cn(res)
  plot = wrf_contour(a,wks,u,res)
  opts  = set_res_highres_coast(True)
  map = wrf_map_overlays(a,wks,plot,True,opts)

end
