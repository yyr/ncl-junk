; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
; Created: Thursday, July 11 2013
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>

import("yagUtils")

begin
  a = set_inputfile()
  lev = 1000
  t = 95
  out  = "wind_p" + lev       ;out put file name
  type = "pdf"

  wks = gsn_open_wks(type,out)
  gsn_reverse_colormap(wks)

  p  = wrf_user_getvar(a,"pressure",t)
  u_1 = wrf_user_getvar(a,"ua",t)
  v_1 = wrf_user_getvar(a,"va",t)

  u = wrf_user_intrp3d(u_1,p,"h",lev,0.,False)
  v = wrf_user_intrp3d(v_1,p,"h",lev,0.,False)

  res = True
  res =  set_res_vc(res)
  plot = wrf_vector(a,wks,u,v,res)
  opts  = set_res_highres_coast(True)
  map = wrf_map_overlays(a,wks,plot,True,opts)

end
