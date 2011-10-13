; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: printvarsummery.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Thursday, October 13 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
; USAGE: ncl 'vname="PHB"' ~/nsc/printvarsummery.ncl

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

  if ( .not.isvar("vname") ) then

    print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
    print("No var name is given;")
    print("Exmaple: ncl vname='PHB' printvarsummery.ncl")
    print("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
    vname="pressure"

 end if

  var = wrf_user_getvar(a,vname,2)

  printVarSummary(var)

end
