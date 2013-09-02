; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
; Created: Friday, July 12 2013
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>

load "$nsc/yagUtils.ncl"

begin
  a = set_inputfile()
  lev = 950
  t = 95
  out  = "v_p" + lev       ;out put file name
  type = "pdf"

  wks = gsn_open_wks(type,out)
  gsn_reverse_colormap(wks)

  p  = wrf_user_getvar(a,"pressure",t)
  v_1 = wrf_user_getvar(a,"va",t)

  v = wrf_user_intrp3d(v_1,p,"h",lev,0.,False)

  res = True
  set_res_cn_limits(res,-30.,5.,1)
  res =  set_res_cn(res)
  plot = wrf_contour(a,wks,v,res)
  opts  = set_high_res_coast(True)
  map = wrf_map_overlays(a,wks,plot,True,opts)

end
