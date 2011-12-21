; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: station_marks.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Tuesday, December 20 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
;

load "$nsc/yagUtils.ncl"

begin

  a = addfile("./wrfout_d01_2008-12-25_00:00:00.nc","r")
  type = "ps"
  out = "topo_station_marks"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"BlueWhiteOrangeRed")

  res = True
  res@cnFillOn = True

  hgt = a->HGT
  landmask =  a->LANDMASK
  hgt = hgt+(landmask * 1)

  plot_hgt = wrf_contour(a,wks,hgt(1,:,:),res)
  pl = wrf_map_overlays(a,wks,(/plot_hgt/),True,True)

end
;;; station_marks.ncl ends here
