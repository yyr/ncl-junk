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

  type = "png"
  wks = gsn_open_wks(type,"hov")
  gsn_define_colormap(wks,"BlueRedGray")

  varname = "QSNOW"

  planes = (/(/217,378,98,372/),(/252,350,80,301/), (/300,378,56,176/) , \
          (/303,382,62,237/)/)
  plane = new(4,float)
  plane = planes(3,:)

; get time information and strip out the day and hour
  times_in_file = a->Times

  dimt = filevardimsizes(a,varname)
  nt = dim_len0(times_in_file)

  st_time = 48
  wgted_var = new((/ nt - st_time ,dimt(2),dimt(3)/),float)

  times = new(nt,string)
  do it = st_time, nt-1, 1   ;; times
    dummy = it - st_time
    wgted_var(dummy,:,:) = wrf_user_getvar_weighted_sum(a,varname,it)

    times(dummy) = chartostring(times_in_file(it,8:12))
    print("working with time:" + times(dummy))
    dummy = dummy + 1
  end do

  wgted_var = wgted_var * 1000.

  dims = dimsizes(wgted_var)

  opts = True                             ; start and end point not supplied
  angle = 0.                    ; intialize
  angle = angle_with_horizontal(plane(0),plane(1),plane(2),plane(3))

  t_plane = wrf_user_intrp2d(wgted_var,plane,angle,opts)

  res = True
  res@trYReverse          = True                ; reverse y axis

  res@cnLineLabelAngleF   = 0.0                 ; [cn] label horizontal
  res@cnFillOn = True

  res@tiMainString = "time series along cross section line"

  res@tmYLMode       = "Explicit"    ; Define own tick mark labels.
  res@tmYLValues     =  fspan(0,dim_len0(times),dim_len0(times))         ; location of explicit labels
  res@tmYLLabels     = times         ; labels are the locations
  res@tmYLMaxTicks = 10
  res@tmYLLabelStride = 8
  res@tmYLMinorOn = False
  res@tmYROn         = False         ; turn off the top tick marks
  res@tmXBLabelFontHeightF = 0.014
  res@tmYLLabelFontHeightF = 0.014

  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels = fspan(0.,2.6,14)

  res@lbOrientation = "vertical"
  res@gsnSpreadColors = True

  plot = gsn_csm_hov(wks,t_plane,res)

end
;;; hov.ncl ends here
