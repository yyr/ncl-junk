;    File: cs_poly.ncl
; Created: Monday, November 14 2011

load "$nsc/yagUtils.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

  type = "X11"
  varname = "HGT"

  wks = gsn_open_wks(type,"cs_line")
  set_colormap(wks,varname)

  ;; initialize resorces
  res = True
  opts = True

  pltres = True
  mpres = True
  mpres = set_high_res_coast(mpres)

  ;; retrieve needed variables
  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)
  ter = a->HGT(0,:,:)

  angle = 0.
  plane = new(4,float)
  plane = (/300,378,56,176/)

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


  pltres@FramePlot = False

  optsM = res
  optsM@NoHeaderFooter = True
  optsM@cnFillOn = True
  optsM@lbTitleOn = False
  optsM@cnLevelSelectionMode = "ExplicitLevels"
  optsM@cnLevels = (/1.,100.,200.,400.,800.,1600.,2400./)
;  optsM@lbOrientation = "vertical"

  optsM@gsnMaximize = True
  optsM@gsnFrame = False              ; Do not advance frame

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
