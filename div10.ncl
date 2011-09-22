; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: div10.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Friday, September  9 2011
; Licence: GPL v3 or later.
;  You should get a copy from <http://www.gnu.org/licenses/gpl.html>
;

; Description:
;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load wrf.div "./wrf.div.so"

begin
;-------------------------------------------------------------------
; USER OPTIONS
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

  level=1

  type = "ps"
  out = "div10"      ;out put file name

  wks = gsn_open_wks(type,out)

  res = True
  res@Footer = False
  res@gsnSpreadColors = True    ;spread Colors
  res@lbLabelBarOn        = False           ; turn off individual cb's

  mpres  = True  ; Map resources
  pltres = True ; Plot resources
  mpres@mpDataBaseVersion    = "HighRes"
  mpres@mpGeophysicalLineThicknessF = 2.0

  u = wrf_user_getvar(a,"U10",tvalues(it))
  v = wrf_user_getvar(a,"V10",tvalues(it))

;-------------------------------------------------------------------
  res@gsnDraw              = True              ; Do not draw plot
  res@gsnFrame             = True              ; Do not advance frame

  res@cnInfoLabelOn = False        ; turn off contour info label

;-------------------------------------------------------------------
; contour resources
  opts = res
  opts@cnFillOn = True
  opts@cnFillColor = True
; opts@ContourParameters = (/ 265.,275., 0.5 /)
  opts@InitTime = False
; opts@ValidTime = False

;-------------------------------------------------------------------
; plot resources
  pltres@NoTitles = True
  pltres@PanelPlot = True

; map resources
  mpres@gsnMaximize = True
; mpres@MainTitlePos= False

;-------------------------------------------------------------------
; plot each one
; contour = wrf_contour(a,wks,tc(level,:,:),opts)
  contour = wrf_contour(a,wks,div10(:,:),opts)
  plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
  delete(contour)

end
