; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: wind10.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Friday, September 22 2011
; License: GPL v3 or later.
;  You should get a copy from <http://www.gnu.org/licenses/gpl.html>
;

; Description:
;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;--------------------------------------------------------------------
; input file

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  tvalues = (/ 48,60,72,84,90,96 /)   ;specify desired timestep outputs must be even

  type = "ps"
  out  = "slp_wind10_pan"       ;out put file name


;--------------------------------------------------------------------
  wks = gsn_open_wks(type,out)

;--------------------------------------------------------------------
; some initial resources

  res = True
  res@Footer = False
  res@gsnSpreadColors = True    ;spread Colors

  mpres  = True  ; Map resources
  pltres = True ; Plot resources
  mpres@mpDataBaseVersion    = "HighRes"
  mpres@mpGeophysicalLineThicknessF = 2.0
  mpres@mpGeophysicalLineColor = "Blue"

  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

;--------------------------------------------------------------------
; Do looping
  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 0, noft - 1, 1   ; LOOP NAME
                                ; do it = 60, ntimes-1, 2  ; LOOP NAME
    print("tvalue: " + tvalues(it))

    print("Working on time: " + times(tvalues(it)))
    res@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots
                                ; res@gsnLeftString = times(tvalues(it))   ; Set Valid time to use on plots

    u10 = wrf_user_getvar(a,"U10",tvalues(it))   ; U component of the wind at 10m
    v10 = wrf_user_getvar(a,"V10",tvalues(it))   ; V component of the wind at 10m
    slp = wrf_user_getvar(a,"slp",tvalues(it))

    res@gsnDraw              = False              ; Do not draw plot
    res@gsnFrame             = False              ; Do not advance frame



;--------------------------------------------------------------------
; resources for contour plot
    cres = res
    cres@cnFillOn         = False
    cres@cnLevelFlags = True
    cres@ContourParameters = (/ 972., 996., 3 /)
    cres@InitTime = False
    cres@gsnPanelRight = True

    contour = wrf_contour(a,wks,slp,cres)
    delete(cres)



;--------------------------------------------------------------------
; Plotting options for Wind Vectors
    opts = res
    opts@FieldTitle = "Wind"       ; overwrite Field Title
                                ; opts@NumVectors = 40           ; density of wind barbs
    opts@InitTime = False
    opts@ValidTime = False
    opts@vcGlyphStyle = "LineArrow"
    opts@vcMonoLineArrowColor = False
    opts@gsnSpreadColors     = True      ; use full colormap
    opts@vcGlyphStyle        = "CurlyVector"    ; turn on curly vectors


;--------------------------------------------------------------------
; plot resources
    pltres@NoTitles = True
    pltres@PanelPlot = True
    pltres@FramePlot = False
    pltres@MainTitlePos= False

;--------------------------------------------------------------------
; map resources

    mpres@gsnMaximize = True
;; mpres@MainTitlePos= False

;--------------------------------------------------------------------
; plot each one

    vector = wrf_vector(a,wks,u10(:,:),v10(:,:),opts)
    plot(it) = wrf_map_overlays(a,wks,(/vector,contour/),pltres,mpres)
    delete(vector)

  end do

;--------------------------------------------------------------------
; panalize here

  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 4                ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@gsnMaximize = True

  pres@txString         = "Wind at 10"
  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end
