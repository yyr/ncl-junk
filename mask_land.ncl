; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
; Created: Friday, March  8 2013
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
import("yagUtils")


begin
  tmp = "/home/yagnesh/wrf/run/20071116/d3/wrfout_d03_2007-11-14_00:00:00"
  tmp_fh = addfile(tmp + ".nc","r")

  xland = wrf_user_getvar(tmp_fh,"XLAND",0)
  coard = (/213,372,92,218/)

  lo = coard(0)                      ; left lon
  ro = coard(1)                      ; right lon
  la = coard(2)                       ; left lat
  ra = coard(3)                      ; right lat


  b = where(xland .eq. 1 , 0 , 1)

  b_a = b(lo:ro,la:ra)

  wks=gsn_open_wks("ps","tmp")

  res = True
  res@gsnSpreadColors = True
  res@cnLevels = (/0,1/)

  printVarInfo(b_a,"tmp")
  plot = gsn_csm_contour(wks,b_a,res)

end
