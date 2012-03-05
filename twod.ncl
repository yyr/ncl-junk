; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: vint.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Tuesday, October 11 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
; compute vertical integation of a given variable

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
                                ; a = addfile("./wrfout_d03_2008-12-23_00:00:00.nc","r")
  type = "x11"
  type = "ps"
  var = "qsnow"
  out = "vint_" + var       ;out put file name

  wks = gsn_open_wks(type,out)

  res = True

  times  = wrf_user_list_times(a)  ; get times in the file

  qv = wrf_user_getvar(a,"QSNOW",77)
  qv = qv*1000.
  qv@units = "g/kg"

  printVarSummary(qv)

  qv_sum = qv(1,:,:)
  do eta = 1, noflevels, 1   ;; eta
    qv_sum = qv_sum + qv(eta,:,:)
  end do
  printVarSummary(qv_sum)

  contour = wrf_contour(a,wks,qv_sum,res)

  plot =wrf_map_overlays(a,wks,(/contour/),True,True)

end