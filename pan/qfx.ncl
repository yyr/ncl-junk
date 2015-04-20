;;  Author: Yagnesh Raghava Yakkala <hi@yagnesh.org>
;; Created: Wednesday, September 21 2011

import("yag_utils")

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  type = "pdf"
  out = "mflux"       ;out put file name

  tvalues = (/ 47, 78, 82, 86, 90,94/)   ;specify desired timestep outputs must be even

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"hotcold_18lev")

  res = True

  res@Footer = False
  res@gsnSpreadColors = True    ;spread Colors
  res@lbLabelBarOn        = False

  mpres  = True
  pltres = True
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

    mflux = wrf_user_getvar(a,"QFX",tvalues(it))

    res@gsnDraw   = False
    res@gsnFrame  = False
    res@cnInfoLabelOn = False

    opts = res
    opts@cnFillOn         = True
    opts@ContourParameters = (/ 0., 0.0002, 0.00005 /)
    opts@cnFillColor = True
    opts@InitTime = False


    pltres@NoTitles = True
    pltres@PanelPlot = True
    pltres@FramePlot = False

    mpres@NoHeaderFooter = True

    contour = wrf_contour(a,wks,mflux,opts)

    plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
    delete(contour)

  end do

  pres                = True
  pres@lbLabelStride  = 7
  pres@gsnPanelBottom = 0.05
  pres@gsnPanelLabelBar = True

  pres@txString         = "Upward moisture flux at the surface (kg m-2 s-1)  "
  gsn_panel(wks,plot,(/noft/2 , 2/),pres)

end
