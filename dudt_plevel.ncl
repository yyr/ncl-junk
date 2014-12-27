; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
; Created: Friday, July 12 2013
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>

import("yag_utils")

begin
  a = set_inputfile()
  levels = (/950, 850 /)
  t1 = 95
  t2 = 94

  do lev = 0, dim_len0(levels) -1, 1
    announce("level: " + levels(lev))
    out  = "dudt_p" + levels(lev)       ;out put file name
    type = "pdf"

    wks = gsn_open_wks(type,out)
    gsn_reverse_colormap(wks)

    p  = wrf_user_getvar(a,"pressure",t1)
    u_1 = wrf_user_getvar(a,"ua",t1)
    v_1 = wrf_user_getvar(a,"va",t1)

    u1 = wrf_user_intrp3d(u_1,p,"h",levels(lev),0.,False)
    v1 = wrf_user_intrp3d(v_1,p,"h",levels(lev),0.,False)

    p  = wrf_user_getvar(a,"pressure",t2)
    u_2 = wrf_user_getvar(a,"ua",t2)
    v_2 = wrf_user_getvar(a,"va",t2)

    u2 = wrf_user_intrp3d(u_2,p,"h",levels(lev),0.,False)
    v2 = wrf_user_intrp3d(v_2,p,"h",levels(lev),0.,False)

    u = u1 - u2
    v = v1 - v2

    res = True
    res =  set_res_vc(res)
    plot = wrf_vector(a,wks,u,v,res)
    opts  = set_res_highres_coast(True)
    map = wrf_map_overlays(a,wks,plot,opts,opts)
  end do


end
