;; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;;    File: map_factor.ncl
;;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
;; Created: Tuesday, September 20 2011
;; Licence: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;;

;; Description:
;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  type = "ps"

  msft = wrf_user_getvar(a,"MAPFAC_M",1 )

  printVarSummary(msft)
  wks = gsn_open_wks(type,"msft_M")
  gsn_define_colormap(wks,"WhBlGrYeRe")   ; overwrite the .hluresfile color map

  res = True
  res@Footer = False
  ;; res@gsnSpreadColors = True    ;spread Colors

  mpres  = True  ; Map resources
  pltres = True ; Plot resources

  opts = res
  ;; opts@cnFillOn         = True
  opts@NoHeaderFooter   = False
  opts@Footer = False
  opts@InitTime = False

  contour = wrf_contour(a,wks,msft,opts)
  plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)

end
