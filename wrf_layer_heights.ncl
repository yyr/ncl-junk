; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
; Created: Wednesday, February  6 2013
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>

; plot the height of wrf levels at given location.
import("yagUtils")

begin
  a = set_inputfile()

  wks = gsn_open_wks("ps","hgt")
  hgt = wrf_user_getvar(a,"height", 1)

  res = wrf_map_resources(a,True)
  res = set_res_no_frame(res)

  printVarInfo(hgt,"var")
  plot = gsn_csm_contour_map(wks,hgt(10,:,:),res)

  draw(wks)
  frame(wks)

end
