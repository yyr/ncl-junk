; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: hov.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Monday, November 14 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
;

load "$nsc/yagUtils.ncl"

begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

; We generate plots, but what kind do we prefer?
  type = "ps"
  wks = gsn_open_wks(type,"hov")

  varname = "QSNOW"

; get time information and strip out the day and hour
  times_in_file = a->Times

  dim = dimsizes(times_in_file)
  times = new(dim(0),string)

  xlon = wrf_user_getvar(a, "XLONG",0)

  dimt = filevardimsizes(a,varname)
  nd = dimsizes(dimt)

  dummy = 0
  st_time = 48
  tmp = dim(0)- st_time
  taus = fspan(st_time,dim(0)-1,tmp)
  taus = taus - st_time + 1

  wgted_var = new((/tmp,dimt(2),dimt(3)/),float)

  do it = st_time, dim(0)-1, 1   ;; times
    wgted_var(dummy,:,:) = wrf_user_getvar_weighted_sum(a,varname,it)

    times(dummy) = chartostring(times_in_file(it,8:12))
    print("working with time:" + times(dummy))
    dummy = dummy + 1
  end do

  wgted_var = wgted_var * 1000.

  dims = dimsizes(wgted_var)

  plane = new(4,float)
  plane = (/205,12,296,199/)
;  plane = (/89,52,216,218/)
  angle = 45.                              ; plot from west to east
  opts = True                             ; start and end point not supplied
  ;; plane = (/ dims(2)/2, dims(1)/2 /)       ; pivot point (x,y) through center of domain
  ;; angle = 45.                              ; plot from west to east
  ;; opts = False                             ; start and end point not supplied

  t_plane = wrf_user_intrp2d(wgted_var,plane,angle,opts)

  res = True
  res@trYReverse          = True                ; reverse y axis

  res@cnLineLabelAngleF   = 0.0                 ; [cn] label horizontal
  res@cnFillOn = True
  res@tiMainString = "Hovmueller plot"
  res@tmYLMode       = "Explicit"    ; Define own tick mark labels.
  res@tmYLValues     = taus          ; location of explicit labels
  res@tmYLLabels     = times         ; labels are the locations
  res@tmYLLabelStride = 6
  res@tmYROn         = False         ; turn off the top tick marks

  res@gsnSpreadColors = True

  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = (/0.,0.2,0.4,.6,.8,1.,1.2,1.4,1.6,1.8,2.0,2.2,2.4,2.6/)
  res@lbOrientation = "vertical"

  plot = gsn_csm_hov(wks,t_plane,res)

end
;;; hov.ncl ends here
