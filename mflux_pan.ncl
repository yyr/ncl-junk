;; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;;    File: mflux_pan.ncl
;;  Author: Yagnesh Raghava Yakkala <hi@yagnesh.org>
;; Created: Wednesday, September 21 2011
;; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;;

;; Description:
;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  type = "pdf"
  out = "mflux"       ;out put file name

  tvalues = (/ 47, 78, 82, 86, 90,94/)   ;specify desired timestep outputs must be even

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"hotcold_18lev")

  res = True
  ;; res@MainTitle = "Water Vapour Mixing Ration"
  res@Footer = False
  res@gsnSpreadColors = True    ;spread Colors
  res@lbLabelBarOn        = False           ; turn off individual cb's

  mpres  = True  ; Map resources
  pltres = True ; Plot resources
  mpres@mpDataBaseVersion    = "HighRes"
  mpres@mpGeophysicalLineThicknessF = 2.0

  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 0, noft - 1, 1   ;; LOOP NAME

    print("Record Number: " + tvalues(it))
    print("Working on time: " + times(it) )

    res@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots

    mflux = wrf_user_getvar(a,"QFX",tvalues(it))

    res@gsnDraw   = False              ; Do not draw plot
    res@gsnFrame  = False              ; Do not advance frame
    res@cnInfoLabelOn = False        ; turn off contour info label

    opts = res
    opts@cnFillOn         = True
    opts@ContourParameters = (/ 0., 0.0002, 0.00005 /)
    opts@cnFillColor = True
    opts@InitTime = False
    ;; opts@NoHeaderFooter = True

    pltres@NoTitles = True
    pltres@PanelPlot = True
    pltres@FramePlot = False

    mpres@NoHeaderFooter = True

    contour = wrf_contour(a,wks,mflux,opts)

    plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
    delete(contour)

  end do

  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 7           ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar

  pres@txString         = "Upward moisture flux at the surface (kg m-2 s-1)  "      ; add common title
  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end
