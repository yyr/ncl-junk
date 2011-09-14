;; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;;    File: panel_t.ncl
;;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
;; Created: Friday, September  9 2011
;; Licence: GPL v3 or later.
;;  You should get a copy from <http://www.gnu.org/licenses/gpl.html>
;;

;; Description:
;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
  ;;--------------------------------------------------------------------
  ;; USER OPTIONS
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  ;; a = addfile("./wrfout_d03_2008-02-11_00:00:00.nc","r")

  ;; type = "x11"
  type = "ps"
  pressure = 850.               ;which level you want to plot
  out = "pan_tsk"       ;out put file name

  tvalues = (/ 47, 78, 82, 86, 90,94/)   ;specify desired timestep outputs must be even

  ;;--------------------------------------------------------------------
  ;; Workstation settings
  wks = gsn_open_wks(type,out)
  ;; gsn_define_colormap(wks,"BlueRedGray")   ; overwrite the .hluresfile color map
  gsn_define_colormap(wks,"BlWhSmall")   ; overwrite the .hluresfile color map

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
  ;; do it = 60, ntimes-1, 2  ;; LOOP NAME
    print("tvalue: " + tvalues(it))

    print("Working on time: " + times(it) )
    res@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots

    tsk = wrf_user_getvar(a,"TSK",it)
    u10  = wrf_user_getvar(a,"U10",it)        ; u averaged to mass points
    v10  = wrf_user_getvar(a,"V10",it)        ; v averaged to mass points

    ;;--------------------------------------------------------------------
    ;;
    res@gsnDraw              = False              ; Do not draw plot
    res@gsnFrame             = False              ; Do not advance frame
    res@cnInfoLabelOn = False        ; turn off contour info label

;;--------------------------------------------------------------------
    ;; contour resources
    opts = res
    opts@cnFillOn         = True
    opts@cnLevelSelectionMode = "ExplicitLevels"
    opts@cnLevels =  fspan(265.,285.,40)
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
    ;; Vector
    optsV = True
    optsV@FieldTitle = "Wind"   ; overwrite Field Title
    optsV@NumVectors = 47       ; wind barb density


    ;;--------------------------------------------------------------------
    ;; plot each one
    contour = wrf_contour(a,wks,tsk,opts)
    ;; Plotting options for Wind Vectors
    vector = wrf_vector(a,wks,u10,v10,optsV)

    plot(it) = wrf_map_overlays(a,wks,(/contour, vector/),pltres,mpres)
    delete(contour)
    delete(vector)

  end do

  ;;--------------------------------------------------------------------
  ;; panalize here
  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 10             ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar

  pres@txString         = "Skin Temperature "      ; add common title
  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end
