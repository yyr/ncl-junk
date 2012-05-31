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
  type = "png"
;  type = "x11"
  wks = gsn_open_wks(type,"diff_p_pan")
  tvalues = (/ 48,96 /)   ;specify desired timestep outputs must be even

  varname = "slp"

; get time information and strip out the day and hour

  last_ind = last(a,"Times",0)
  times  = wrf_user_list_times(a)  ; get times in the file

  xlon = wrf_user_getvar(a, "XLONG",0)

  dimt = filevardimsizes(a,"XLONG")
  nd = dimsizes(dimt)

  st_time = 70

                                ;--------------------------------------------------------------------
  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  ts_len = last_ind - st_time + 1
  ts = fspan(st_time,last_ind,ts_len)
  ts = ts - st_time + 1

  height = 1500.   ; height at which pressure to be extracted

  res = True
;  res@cnFillOn         = True
;  res@gsnSpreadColors = True
  res@gsnDraw              = False              ; Do not draw plot
  res@gsnFrame             = False              ; Do not advance frame

do it = 0, noft - 1, 1   ; LOOP NAME

    vt = tvalues(it)
;  do vt = st_time, last_ind,2   ;; times
;  do vt = 90 ,92

    print("working with time:" + times(vt))
    slp = wrf_user_getvar(a,varname,vt)

    p  = wrf_user_getvar(a, "pressure",vt) ; pressure is our vertical coordinate
    z  = wrf_user_getvar(a, "z",vt)        ; grid point height
    p_plane  = wrf_user_intrp3d( p,z,"h",height,0.,False)

    p_diff = slp-p_plane

    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels = fspan(171,180,45)

    plot=wrf_contour(a,wks,p_diff,res)

    mpres  = res  ; Map resources
    mpres@mpDataBaseVersion    = "HighRes"
    mpres@mpGeophysicalLineThicknessF = 2.0

    pltres = res ; Plot resources
    pltres@NoTitles = True
    pltres@NoHeaderFooter = True

    plot(it) = wrf_map_overlays(a,wks,(/plot/),pltres,mpres)
    delete(pltres)
    delete(mpres)


  end do
  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 4                ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@gsnMaximize = True
;  pres@lbOrientation = "Vertical"

  pres@txString         = "Pressure Diff"
  gsn_panel(wks,plot,(/1,noft/),pres)        ; create panel plot

end
;;; cs_hgt.ncl ends here
