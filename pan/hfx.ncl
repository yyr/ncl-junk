;;    File: hflux.ncl
;; Created: Wednesday, September 21 2011

import("yag_utils")

begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  type = "pdf"
  out = "hflux_pan"

  tvalues = (/ 47, 78, 82, 86, 90,94/)

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"hotcold_18lev")

  res = True
  res@Footer = False
  res@gsnSpreadColors = True
  res@lbLabelBarOn        = False

  mpres  = True  ; Map resources
  pltres = True ; Plot resources
  mpres@mpDataBaseVersion    = "HighRes"
  mpres@mpGeophysicalLineThicknessF = 2.0

  times  = wrf_user_list_times(a)
  ntimes = dimsizes(times)

  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 0, noft - 1, 1

    print("Record Number: " + tvalues(it))
    print("Working on time: " + times(it) )

    res@TimeLabel = times(tvalues(it))

    hflux = wrf_user_getvar(a,"HFX",tvalues(it))

    res@gsnDraw   = False
    res@gsnFrame  = False
    res@cnInfoLabelOn = False

    opts = res
    opts@cnFillOn         = True
    opts@ContourParameters = (/ -100., 500., 50 /)
    opts@cnFillColor = True
    opts@InitTime = False

    pltres@NoTitles = True
    pltres@PanelPlot = True
    pltres@FramePlot = False

    mpres@NoHeaderFooter = True

    contour = wrf_contour(a,wks,hflux,opts)

    plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
    delete(contour)

  end do

  pres                = True
  pres@lbLabelStride  = 3
  pres@gsnPanelBottom = 0.05
  pres@gsnPanelLabelBar = True

  pres@txString         = "Upward heat flux at the suraface (W m-2) "
  gsn_panel(wks,plot,(/noft/2 , 2/),pres)

end
