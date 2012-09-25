; Purpose: make a poly marker line between given points on the domain
;      (background terrian contour)

load "$nsc/yagUtils.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

  ;; changes here
  angle = 0.
  planes = (/(/217,378,98,372/),(/252,350,80,301/), (/300,378,56,176/) , \
          (/303,382,62,237/)/)

  type = "png"
  varname = "HGT"

  wks = gsn_open_wks(type,"line")
  set_colormap(wks,varname)

  ;; draw height contours
  mpres = True
  plot = hgt_contour(a,wks,mpres)
  draw(plot)

;- draw polyline
  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  do it = 3, 3

    plane = new(4,float)
    plane = planes(it,:)

    opts = True
    lat_plane = wrf_user_intrp2d(xlat,plane,angle,opts)
    lon_plane = wrf_user_intrp2d(xlon,plane,angle,opts)

    lnres = True
    lnres@gsLineThicknessF = 3.0
    lnres@gsLineColor = "Red"

    dimsX = dimsizes(lon_plane)
    xmin  = lon_plane(0)
    xmax  = lon_plane(dimsX(0)-1)
    xspan = dimsX(0)-1

    print(lon_plane)
    do ii = 0,dimsX(0)-2
      gsn_polyline(wks,plot,(/lon_plane(ii),lon_plane(ii+1)/),(/lat_plane(ii),lat_plane(ii+1)/),lnres)
    end do

    delete(plane)
    delete(lon_plane)
    delete(lat_plane)
  end do

  frame(wks)

end
