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

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  out = "station_marks"
  type = "pdf"

  st1 = (/125,124/)
  st2 = (/145,129/)

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"BlueWhiteOrangeRed")



  hgt = a->HGT
  landmask =  a->LANDMASK
  hgt = hgt+(landmask * 1)


  res = True
  res_poly               = True
  res_poly@gsMarkerIndex = 16
  res_poly@xyMarker      = 6.
  res_poly@xyMarkers     = (/2,5,12/)

  op = res
  op@gsnSpreadColors = True    ;spread Colors
  op@cnFillOn = True
  op@cnLinesOn = False
  op@Footer = False
  op@InitTime = False


  mp = True
  mp@mpDataBaseVersion    = "HighRes"
  mp@mpGeophysicalLineThicknessF = 2.0
  mp@pmTickMarkDisplayMode = "Always"

  mp@mpGeophysicalLineColor      = "Black"
  mp@mpGridLineColor             = "Black"
  mp@mpLimbLineColor             = "Black"
  mp@mpNationalLineColor         = "Black"
  mp@mpPerimLineColor            = "Black"

  plot_hgt = wrf_contour(a,wks,hgt(1,:,:),op)
  gsn_polymarker(wks,plot_hgt,(/st1(0),st2(0)/),(/st1(1),st2(1)/),res_poly)

  pl = wrf_map_overlays(a,wks,(/plot_hgt/),op,mp)

end
;;; station_marks.ncl ends here
