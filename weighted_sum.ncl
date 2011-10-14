; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: weighted_sum.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Wednesday, October 12 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
; weithted sum: from Hydrostatic equation
; dP/dz = - ro * g (ro = density )
;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;--------------------------------------------------------------------
; USER OPTIONS
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
;  a = addfile("./wrfout_d03_2008-12-23_00:00:00.nc","r")
                                ; type = "x11"
  type = "ps"
  varname = "QSNOW"
  g = 9.8                       ; gravity

  out = "wgt_sum_" + varname       ;out put file name

  wks = gsn_open_wks(type,out)

  noflevels = 32                ; how many layers should be added


  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

;--------------------------------------------------------------------

  it = 88

  var = wrf_user_getvar(a,varname,it)
  ph = wrf_user_getvar(a,"PH",it)
  phb = wrf_user_getvar(a,"PHB",it)
  pres = wrf_user_getvar(a,"pressure",it)
  gh = ph + phb               ;geo potential height
                                ; print(qice(12,:,:))
  dim = dimsizes(var)
  wgt_var = new((/ dim(1),dim(2) /),typeof(var))

  wgt_var = 0

  do z = 0, noflevels, 1   ; z level

    lay_var = (var(z+1,:,:) + var(z,:,:)) ; interpolation of the variable
    lay_var = lay_var/2.

    dgh = gh(z+1,:,:) - gh(z,:,:) ; gh difference bw two layers
    dp = pres(z+1,:,:) - pres(z,:,:) ; pressure difference bw two layers

    lay_wgt = (dp/dgh)
    lay_wgt = lay_wgt * g     ;

    lay_wgt_var = lay_var * lay_wgt * - 1. ; '-' from hydrostaic eq

    wgt_var = wgt_var + lay_wgt_var ;* 1/mean_levels)

  end do
  wgt_var = wgt_var * 1000. ;
  wgt_var@units = "g"

;--------------------------------------------------------------------
; some initial resources
  res = True
  res@gsnSpreadColors = True    ;spread Colors
  res@TimeLabel = times(it)   ; Set Valid time to use on plots
  res@Footer = False

;--------------------------------------------------------------------
; contour resources
  opts = res
  opts@cnFillOn         = True
  opts@cnFillColor = True
  opts@ContourParameters = (/ 0., 2.6, .2 /)
;  opts@lbLabelBarOn        = False           ; turn off individual cb's
  opts@InitTime = False

  mpres  = True  ; Map resources
  pltres = True ; Plot resources

  contour = wrf_contour(a,wks,wgt_var,opts)
  plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)

end
