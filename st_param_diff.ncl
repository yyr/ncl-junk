; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: st_param_diff.ncl
; Created: Monday, March  5 2012
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

  stime=48
  etime=95

  param = "T2"
  type = "pdf"
  out = "st_" + param + "_diff"     ;out put file name

  st1 = (/125,124/)
  st2 = (/145,129/)

end
;;; st_param_diff.ncl ends here
