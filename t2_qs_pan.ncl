; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: t2_qs_pan.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Monday, November 14 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
;

load "$nsc/yagUtils.ncl"

begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  tvalues = (/ 48,60,72,84,90,96 /)   ;specify desired timestep outputs must be even

  type = "ps"
  out = "t2_qs_pan"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"BlueGreen14")   ; overwrite the .hluresfile color map

  varname = "QSNOW"
  noflevels = 32                ; how many layers should be added

  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

;--------------------------------------------------------------------
  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

;;--------------------------------------------------------------------
; res
  res = True
  res@Footer = False
  res@gsnDraw              = False              ; Do not draw plot
  res@gsnFrame             = False              ; Do not advance frame


  do it = 0, noft - 1, 1   ; LOOP NAME

    vt = tvalues(it)
;     vt = tvalues(it) + 96
;  notify time
    print("working with: " + times(vt))


;;--------------------------------------------------------------------
;;-- qsnow  --
    wgted_var = wrf_user_getvar_weighted_sum(a,varname,vt)
    wgted_var = wgted_var * 1000. ;
    wgted_var@units = "g"

    res@TimeLabel = times(vt)   ; Set Valid time to use on plots

    opts = res
    opts@ContourParameters = (/ 0., 2.6, .4 /)
    opts@InitTime = False
    contour = wrf_contour(a,wks,wgted_var,opts)
    delete(opts)


;;--------------------------------------------------------------------
;;-- t2  --

    optsT = res
    optsT@cnFillOn         = True
    optsT@cnFillColor = True
    optsT@ContourParameters = (/ 260.,280., 0.5 /)
    optsT@InitTime = False
    optsT@lbLabelBarOn = False
    optsT@cnInfoLabelOn = False        ; turn off contour info label

    t2 = wrf_user_getvar(a,"T2",vt)
    contour_t = wrf_contour(a,wks,t2,optsT)
    delete(optsT)

;;--------------------------------------------------------------------
;;-- plot/overlay all  --
    pltres = True ; Plot resources
    pltres@NoTitles = True
    pltres@MainTitlePos= False
    pltres@PanelPlot = True
    pltres@FramePlot = False

    mpres  = True  ; Map resources
    mpres@mpDataBaseVersion    = "HighRes"
    mpres@mpGeophysicalLineThicknessF = 2.0
    mpres@mpGeophysicalLineColor = "Blue"


;    plot = wrf_map_overlays(a,wks,(/contour,contour_t/),pltres,mpres)
    plot(it) = wrf_map_overlays(a,wks,(/contour_t,contour/),pltres,mpres)
    delete(pltres)
    delete(mpres)

  end do

;--------------------------------------------------------------------
; panalize here

  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 4                ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@gsnMaximize = True
  pres@lbOrientation = "Vertical"

  pres@txString         = "Snow Mixing ration over SST"
  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end
;;; t2_qs_pan.ncl ends here