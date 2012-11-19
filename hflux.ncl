;; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;;    File: hflux.ncl
;;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
;; Created: Wednesday, September 21 2011
;; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;;

;; Description:
;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
  ;;--------------------------------------------------------------------
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  type = "ps"
  out = "hflux"       ;out put file name

  tvalues = (/ 47, 78, 82, 86, 90,94/)   ;specify desired timestep outputs must be even

  ;;--------------------------------------------------------------------
  ;; Workstation settings
  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"hotcold_18lev")

  ;;--------------------------------------------------------------------
  ;; some initial resources
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

  ;;--------------------------------------------------------------------
  ;; Do looping
  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 0, noft - 1, 1   ;; LOOP NAME

    print("Record Number: " + tvalues(it))
    print("Working on time: " + times(it) )

    res@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots

    hflux = wrf_user_getvar(a,"HFX",tvalues(it))

    ;;--------------------------------------------------------------------
    ;;
    res@gsnDraw   = False              ; Do not draw plot
    res@gsnFrame  = False              ; Do not advance frame
    res@cnInfoLabelOn = False        ; turn off contour info label

    ;;--------------------------------------------------------------------
    ;; contour resources
    opts = res
    opts@cnFillOn         = True
    opts@ContourParameters = (/ -100., 500., 50 /)
    opts@cnFillColor = True
    opts@InitTime = False
    ;; opts@NoHeaderFooter = True

    ;;--------------------------------------------------------------------
    ;; plot resources
    pltres@NoTitles = True
    pltres@PanelPlot = True
    pltres@FramePlot = False

    ;;--------------------------------------------------------------------
    ;; map resources
    ;; mpres@gsnMaximize = True
    mpres@NoHeaderFooter = True

    ;;--------------------------------------------------------------------
    ;; plot each one
    contour = wrf_contour(a,wks,hflux,opts)
    ;; Plotting options for Wind Vectors

    plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
    delete(contour)

  end do

  ;;--------------------------------------------------------------------
  ;; panalize here
  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 3             ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar

  pres@txString         = "Upward heat flux at the suraface (W m-2) "      ; add common title
  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end
