; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: wind_plevel.ncl
; Created: Friday, September 22 2011
; Licence: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
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
  tvalues = (/ 0,47,90,92,94,96 /)   ;specify desired timestep outputs must be even

                                ; four_day = "yes"               ; yes or comment out
  if ( isdefined("four_day") ) then
    a = addfile("./wrfout_d03_2008-12-23_00:00:00.nc","r")
    tvalues = tvalues + 96
  end if
                                ; type = "x11"
  type = "ps"
  pressure = 500
  out  = "wind10" + pressure       ;out put file name

;--------------------------------------------------------------------
; Workstation settings

  wks = gsn_open_wks(type,out)
                                ; gsn_define_colormap(wks,"BlAqGrYeOrReVi200")            ; choose color map

;--------------------------------------------------------------------
; some initial resources

  res = True
                                ; res@MainTitle = "Water Vapour Mixing Ration"
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

    u = wrf_user_getvar(a,"U",it)   ; U component of the wind at 10m
    v = wrf_user_getvar(a,"V",it)   ; V component of the wind at 10m

    p  = wrf_user_getvar(a,"pressure",it) ; total pressure
    u_plevel = wrf_user_intrp3d(u,p,"h",pressure,0.,False)
    v_plevel = wrf_user_intrp3d(v,p,"h",pressure,0.,False)

;--------------------------------------------------------------------
;
    res@gsnDraw              = False              ; Do not draw plot
    res@gsnFrame             = False              ; Do not advance frame

;--------------------------------------------------------------------
; Plotting options for Wind Vectors
    opts = res
    opts@FieldTitle = "Wind"       ; overwrite Field Title
                                ; opts@NumVectors = 40           ; density of wind barbs
    opts@InitTime = False
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
                                ; mpres@MainTitlePos= False

;--------------------------------------------------------------------
; plot each one

    vector = wrf_vector(a,wks,u_plevel(:,:),v_plevel(:,:),opts)
    plot(it) = wrf_map_overlays(a,wks,(/vector/),pltres,mpres)
    delete(vector)

  end do

;--------------------------------------------------------------------
; panalize here

  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 6                ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@gsnMaximize = True

  pres@txString         = "Wind at " + pressure + " HPa"
  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end
