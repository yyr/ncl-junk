;    File: cs_poly.ncl
; Created: Monday, November 14 2011

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

  type = "X11"
;  type = "png"

  wks = gsn_open_wks(type,"cs_poly")

  varname = "HGT"

  dimt = filevardimsizes(a,varname)
  nd = dimsizes(dimt)

  hgt = a->$varname$
  plane = new(4,float)
  dims = dimsizes(hgt)

  plane = (/300,56,378,176/)
  opts = True

;  plane = (/ dims(2)/2, dims(1)/2 /)       ; pivot point (x,y) through center of domain
;  angle = 45.                              ; plot from west to east

  xlat = wrf_user_getvar(a, "XLAT",0)
  xlon = wrf_user_getvar(a, "XLONG",0)
  ter = wrf_user_getvar(a, "HGT",0)

  angle = 0.
  X_plane = wrf_user_intrp2d(xlon,plane,angle,opts)
  lat_plane = wrf_user_intrp2d(xlat,plane,angle,opts)
  lon_plane = wrf_user_intrp2d(xlon,plane,angle,opts)

  X_desc = "longitude"


; X-axis lables
  dimsX = dimsizes(X_plane)
  xmin  = X_plane(0)
  xmax  = X_plane(dimsX(0)-1)
  xspan = dimsX(0)-1
  nx    = floattoint((xmax-xmin)/2 + 1)

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
    gsn_polyline(wks,plot,(/lon_plane(ii),lon_plane(ii+1)/),(/lat_plane(ii),lat_plane(ii+1)/),lnres)
    end if

  end do

  frame(wks)
  delete(lon_plane)
  delete(lat_plane)
  pltres@FramePlot = True

end
;;; cs_poly.ncl ends here
