load "$nsc/yagUtils.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

  type = "X11"
  varname = "HGT"

  wks = gsn_open_wks(type,"cs_line")
  set_colormap(wks,varname)

  ;; initialize resorces
  opts = True

  ;; retrieve needed variables
  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  angle = 0.
  plane = new(4,float)
  plane = (/300,378,56,176/)

  lat_plane = wrf_user_intrp2d(xlat,plane,angle,opts)
  lon_plane = wrf_user_intrp2d(xlon,plane,angle,opts)


  mpres = True
  plot = hgt_contour(a,wks,mpres)
  draw(plot)

  lnres = True
  lnres@gsLineThicknessF = 3.0
  lnres@gsLineColor = "Red"

  dimsX = dimsizes(lon_plane)
  xmin  = lon_plane(0)
  xmax  = lon_plane(dimsX(0)-1)
  xspan = dimsX(0)-1
  nx    = floattoint((xmax-xmin)/2 + 1)

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
