;; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;;    File: div.ncl
;;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
;; Created: Tuesday, September 20 2011
;; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;;

;; Description:
;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
external wrfDiv "$nsc/wrf.div.xy.so"
;; external wrfDiv "$nsc/wrf.div.xy.test.so"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

  u = wrf_user_getvar(a,"U10",1)
  v = wrf_user_getvar(a,"V10",1)
  msft = wrf_user_getvar(a,"MAPFAC_V",1)
  printVarSummary(msft)
  dim=dimsizes(u)

  printVarSummary(dim)
  print(dim)
  dx = 1500                  ; horizontal grid distance in x direction
  dy = 1500                  ; horizontal grid distance in y direction

  div=new( (/ dim(0), dim(1) /) , float)

  div(:,:) = 0.

  printVarSummary(div)

  wrfDiv :: DCOMPUTEDIV( div, u, u, msft,dx,dy, dim(0), dim(1) )
  ;; wrfDiv :: DCOMPUTEDIV( div, dim(0), dim(1) )


end
