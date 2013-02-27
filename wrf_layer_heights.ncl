; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
; Created: Wednesday, February  6 2013
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>

; plot the height of wrf levels at given location.

load "$nsc/yagUtils.ncl"
import("shea_util")

begin
  a = set_inputfile()

  wks = gsn_open_wks("ps","hgt")
  hgt = wrf_user_getvar(a,"HGT", 1)

  res = wrf_map_resources(a,True)
  plot = gsn_csm_contour_map(wks,hgt(:,:),True)
end
