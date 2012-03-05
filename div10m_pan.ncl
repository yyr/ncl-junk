; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: div10m.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Thursday, October  6 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  type = "pdf"
  out = "div10"     ;out put file name

  tvalues = (/ 48,55,62,70,85,95 /)   ;specify desired timestep outputs must be even


;;--------------------------------------------------------------------
; Workstation settings

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"BlWhRe")   ; overwrite the .hluresfile color map
  gsn_reverse_colormap(wks)

;--------------------------------------------------------------------
; some initial resources
  res = True
  res@cnInfoLabelOn = False        ; turn off contour info label

  res@Footer = False
  res@gsnSpreadColors = True    ;spread Colors
  res@lbLabelBarOn        = False           ; turn off individual cb's

  pltres = True ; Plot resources
  mpres  = True  ; Map resources
  mpres@mpDataBaseVersion    = "HighRes"
  mpres@mpGeophysicalLineThicknessF = 2.0
  mpres@mpGeophysicalLineColor = "Blue"


  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

;;--------------------------------------------------------------------
; Do looping
  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 0, noft - 1, 1   ; LOOP NAME

    ;;-- notify about time  --
    print("tvalue: " + tvalues(it))
    print("Working on time: " + times(tvalues(it)))

;;--------------------------------------------------------------------
; calculation

    u = a->U10(tvalues(it),:,:)
; v = a->V10(tstep,:,:)
    v = wrf_user_getvar(a,"V10",tvalues(it))
    dim=dimsizes(u)

    dx = 1500                  ; horizontal grid distance in x direction

    div=new( (/ dim(0), dim(1) /) , typeof(u))

    div = uv2dvG(u,v)
    div = div * dx

;;--------------------------------------------------------------------
; set resorces for this iteration
    res@gsnDraw              = False              ; Do not draw plot
    res@gsnFrame             = False              ; Do not advance frame
    res@cnInfoLabelOn = False        ; turn off contour info label
;    res@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots
    res@gsnLeftString = times(tvalues(it))   ; Set Valid time to use on plots

    opts = res
    opts@cnFillOn         = True
    opts@cnFillColor = True
    opts@InitTime = False
    opts@ContourParameters = (/-.2,0.2 , .05 /)

    ;;-- map res  --
    mpres@NoHeaderFooter = True
    opts@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots

   ;;-- plot res  --
    pltres@NoTitles = True
    pltres@PanelPlot = True
    pltres@FramePlot = False

    contour = wrf_contour(a,wks,div,opts)
    plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
    delete(contour)

  end do

  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 3         ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@gsnMaximize = True

  pres@txString         = "Divergenge at 10m"
  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end
