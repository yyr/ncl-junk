; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: cs_poly.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Monday, November 14 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
;

load "$nsc/yagUtils.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  type = "ps"
  wks = gsn_open_wks(type,"cs_poly")

  varname = "HGT"

  dimt = filevardimsizes(a,varname)
  nd = dimsizes(dimt)

  hgt = a->$varname$
  plane = new(4,float)
  dims = dimsizes(hgt)

; plane = (/89,52,216,218/)
  plane = (/205,12,296,199/)
;  plane = (/224,65,296,199/)
;  plane = (/ dims(2)/2, dims(1)/2 /)       ; pivot point (x,y) through center of domain
  angle = 45.                              ; plot from west to east
;  opts = False                             ; start and end point not supplied
  opts = True                             ; start and end point not supplied

  xlat = wrf_user_getvar(a, "XLAT",0)
  xlon = wrf_user_getvar(a, "XLONG",0)
  ter = wrf_user_getvar(a, "HGT",0)

  angle = 45.
  X_plane = wrf_user_intrp2d(xlon,plane,angle,opts)
  lat_plane = wrf_user_intrp2d(xlat,plane,angle,opts)
  lon_plane = wrf_user_intrp2d(xlon,plane,angle,opts)

  X_desc = "longitude"


; X-axis lables
  dimsX = dimsizes(X_plane)
  xmin  = X_plane(0)
  xmax  = X_plane(dimsX(0)-1)
  xspan = dimsX(0)-1
  nx    = floattoint( (xmax-xmin)/2 + 1)

  X_plane = wrf_user_intrp2d(xlon,plane,angle,opts)
  X_desc = "longitude"

  res = True
  mpres = True
  mpres@mpDataBaseVersion    = "HighRes"
  mpres@mpGeophysicalLineThicknessF = 2.0
  mpres@mpGeophysicalLineColor = "Black"

  pltres = True
  pltres@FramePlot = False
  optsM = res
  optsM@NoHeaderFooter = True
  optsM@cnFillOn = True
  optsM@lbTitleOn = False
  contour  = wrf_contour(a,wks,ter,optsM)
  plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
  lnres = True
  lnres@gsLineThicknessF = 3.0
  lnres@gsLineColor = "Red"

  do ii = 0,dimsX(0)-2
    gsn_polyline(wks,plot,(/lon_plane(ii),lon_plane(ii+1)/),(/lat_plane(ii),lat_plane(ii+1)/),lnres)
    if ( ii .eq. 50 ) then
    gsn_polymarker(wks,plot,(/lon_plane(ii),lon_plane(ii+1)/),(/lat_plane(ii),lat_plane(ii+1)/),lnres)
    end if

  end do

  frame(wks)
  delete(lon_plane)
  delete(lat_plane)
  pltres@FramePlot = True

end
;;; cs_poly.ncl ends here
