; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: wind10.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Friday, September 22 2011
; License: GPL v3 or later.
;  You should get a copy from <http://www.gnu.org/licenses/gpl.html>
;

; Description:
;

load "$nsc/yagUtils.ncl"

begin
;--------------------------------------------------------------------
; input file

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  tvalues = (/71, 82, 95, 119 /)   ;specify desired timestep outputs must be even
                                ; type = "x11"
  type = "pdf"
  out  = "wind10"       ;out put file name

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"WhiteYellowOrangeRed")            ; choose color map

  res = True
  res = set_no_frame_res(res)

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
    opts@gsnSpreadColors     = True      ; use full colormap
    opts@vcGlyphStyle        = "CurlyVector"    ; turn on curly vectors
    opts = set_no_frame_res(opts)
    opts = set_vc_res(opts)
    opts@vcRefMagnitudeF = 10.
    opts@vcMonoLineArrowColor = False

    pltres@NoTitles = True
    pltres@PanelPlot = True
    pltres@FramePlot = False
    pltres@MainTitlePos= False
    mpres@MainTitlePos= False

    vector = wrf_vector(a,wks,u10(:,:),v10(:,:),opts)
    plot(it) = wrf_map_overlays(a,wks,(/vector/),pltres,mpres)
    delete(vector)

  end do

  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 6                ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@gsnMaximize = True

;  pres@txString         = "Wind at 10"
  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end
