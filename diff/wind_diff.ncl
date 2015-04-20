; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
; Created: Friday, July 12 2013
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>

import("yag_utils")

begin
  a = set_inputfile()
  lev1 = 850
  lev2 = 950
  ; lev1 = 950
  ; lev2 = 850

  t = 95
  out  = "wind_diff_" + lev1 + "--" + lev2       ;out put file name
  type = "pdf"

  wks = gsn_open_wks(type,out)

  p  = wrf_user_getvar(a,"pressure",t)
  u_1 = wrf_user_getvar(a,"ua",t)
  v_1 = wrf_user_getvar(a,"va",t)

  u1 = wrf_user_intrp3d(u_1,p,"h",lev1,0.,False)
  v1 = wrf_user_intrp3d(v_1,p,"h",lev1,0.,False)

  u2 = wrf_user_intrp3d(u_1,p,"h",lev2,0.,False)
  v2 = wrf_user_intrp3d(v_1,p,"h",lev2,0.,False)

  u = u1 - u2
  v = v1 - v2

  res = True
  res =  set_res_vc(res)
  plot = wrf_vector(a,wks,u,v,res)
  opts  = set_res_highres_coast(True)
  map = wrf_map_overlays(a,wks,plot,True,opts)

end
