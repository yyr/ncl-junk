;; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;;    File: map_factor.ncl
;;  Author: Yagnesh Raghava Yakkala <hi@yagnesh.org>
;; Created: Tuesday, September 20 2011
;; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;;

;; Description:
;;

import("yagUtils")

begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  type = "ps"

  msft = wrf_user_getvar(a,"MAPFAC_M",1 )

  res = set_res_highres_coast(res)
  printVarSummary(msft)
  wks = gsn_open_wks(type,"msft_M")
  gsn_define_colormap(wks,"WhBlGrYeRe")   ; overwrite the .hluresfile color map

  res = True

  contour = wrf_contour(a,wks,msft,opts)
  plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)

end
