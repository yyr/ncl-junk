; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: cs_hgt.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: 2011-11-29 13:08
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
;

load "$nsc/yagUtils.ncl"

begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

; We generate plots, but what kind do we prefer?
  type = "ps"
  wks = gsn_open_wks(type,"cs_hgt")

  varname = "p"

; get time information and strip out the day and hour

  last_ind = last(a,"Times",0)
  times  = wrf_user_list_times(a)  ; get times in the file

  xlon = wrf_user_getvar(a, "XLONG",0)

  dimt = filevardimsizes(a,"XLONG")
  nd = dimsizes(dimt)

  st_time = 70

  ts_len = last_ind - st_time + 1
  ts = fspan(st_time,last_ind,ts_len)
  ts = ts - st_time + 1

  plane = new(4,float)
  plane = (/224,65,296,199/)

;  plane = (/205,12,296,199/)
;  plane = (/89,52,216,218/)
  angle = 45.                              ; plot from west to east
  opts = True                             ; start and end point not supplied


  do it = st_time, 120,2   ;; times

    print("working with time:" + times(it))
    p = wrf_user_getvar(a,varname,it)
    p_plane = wrf_user_intrp2d(slp,plane,angle,opts)

    res = True
    res@tmYLMode = "Manual"
    res@tmYLTickStartF = 973.
    res@tmYLTickEndF = 991.
    res@tmYLTickSpacingF = 3

    res@tiMainString= "SLP along cs line at" + times(it)

    plot = gsn_csm_y(wks,p_plane,res)

  end do

end
;;; cs_hgt.ncl ends here
