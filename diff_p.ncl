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
  wks = gsn_open_wks(type,"diff_p")

  varname = "slp"

  tvalues = (/ 48,60,72,84,90,96,102,108,114 /)   ;specify desired timestep outputs must be even

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
;  plane = (/224,65,296,199/)
  plane = (/205,12,296,199/)
;  plane = (/89,52,216,218/)
  angle = 45.                              ; plot from west to east
  opts = True                             ; start and end point not supplied

  height = 1500.   ; height at which pressure to be extracted

;;--------------------------------------------------------------------
; Do looping
  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 0, noft - 1, 1   ; LOOP NAME

    vt = tvalues(it)
;  do it = st_time, last_ind,2   ;; times

    print("working with time:" + times(vt))
    slp = wrf_user_getvar(a,varname,vt)
    slp_cs_line = wrf_user_intrp2d(slp,plane,angle,opts)

    p  = wrf_user_getvar(a, "pressure",vt) ; pressure is our vertical coordinate
    z  = wrf_user_getvar(a, "z",vt)        ; grid point height
    p_plane  = wrf_user_intrp3d( p,z,"h",height,0.,False)
    p_cs_line = wrf_user_intrp2d(p_plane,plane,angle,opts)

    len_p_plane=dimsizes(p_cs_line)
    x_axis=ispan(1,len_p_plane(0),1)
    diff= slp_cs_line - (1.2 * p_cs_line)

    ;; do n = 0, len_p_plane(0)-1, 1   ;; LOOP NAME
    ;;   tmp = slp_cs_line(n) + "  " + p_cs_line(n) + " " + p_cs_line * 1.3 +" "+ diff(n)
    ;;   print( n + "  "+ tmp+" ")
    ;; end do

    yesL = True

    yesL@vpHeightF= 0.4                    ; change aspect ratio of plot
    yesL@vpWidthF = 0.8

    yesL@trYMinF  = 8.                  ; min value on y-axis
    yesL@trYMaxF  = 15.                   ; max value on y-axis

    yesL@tiMainString= "diff along cs line at" + times(vt)

;    plot = gsn_csm_xy(wks,x_axis,(/slp_cs_line,p_cs_line/),yesL)
    plot = gsn_csm_xy(wks,x_axis,diff,yesL)

  end do


  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 4                ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@gsnMaximize = True
;  pres@lbOrientation = "Vertical"

;  pres@txString         = "D"
;  gsn_panel(wks,plot,(/2, noft/2 /),pres)        ; create panel plot
  gsn_panel(wks,plot,(/3,noft/3/),pres)        ; create panel plot


end
;;; cs_hgt.ncl ends here
