; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: density.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Wednesday, November  2 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
;

load "$nsc/yagUtils.ncl"

begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  tvalues = (/ 0,47,90,92,94,96 /)   ;specify desired timestep outputs must be even

                                ; four_day = "yes"               ; yes or comment out
  if ( isdefined("four_day") ) then
    a = addfile("./wrfout_d03_2008-12-23_00:00:00.nc","r")
    tvalues = tvalues + 96
  end if
  type = "x11"

  ;;type = "ps"
  pressure = 500
  out  = "wind10" + pressure       ;out put file name

  wks = gsn_open_wks(type,out)



end
;;; density.ncl ends here
