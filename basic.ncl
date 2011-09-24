;; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;;    File: basic.ncl
;;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
;; Created: Wednesday, September 21 2011
;; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;;

;; Description:
;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/contributed.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  type = "x11"
  out = "basic"

  wks = gsn_open_wks(type,out)

  res = True
  mpres  = True  ; Map resources
  pltres = True ; Plot resources

end
