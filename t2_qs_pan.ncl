; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: t2_qs_pan.ncl
; Created: Monday, November 14 2011
;

; Description:
;
load "$nsc/yagUtils.ncl"

begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
; tvalues = (/ 84,90,96,102,108,114 /)   ;specify desired timestep outputs must be even
  tvalues = (/71, 82, 95, 119 /)   ;specify desired timestep outputs must be even

  type = "png"
  out = "t2_qs_pan"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"temp_19lev")   ; overwrite the .hluresfile color map

  varname = "QSNOW"
  noflevels = 32                ; how many layers should be added

  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  res = True
  res@Footer = False
  res = set_no_frame_res(res)


  do it = 0, noft - 1, 1   ; LOOP NAME

    vt = tvalues(it)
    print("working with: " + times(vt))

    wgted_var = wrf_user_getvar_weighted_sum(a,varname,vt)
    wgted_var = wgted_var * 1000. ;
    wgted_var@units = "g"

    res@TimeLabel = times(vt)   ; Set Valid time to use on plots


    opts = res
    opts = wrf_map_resources(a,opts)
    opts = set_mp_wrf_map_resources(a,opts)

    opts@ContourParameters = (/ 0., 2.6, .4 /)
    opts@InitTime = False
    opts@cnInfoLabelOn = False

    contour = gsn_csm_contour_map(wks,wgted_var,opts)
    delete(opts)


    ;;-- t2  --

    optsT = res
    optsT@cnFillOn         = True
    optsT@cnInfoLabelOn = False
    optsT@cnFillColor = True
    optsT@ContourParameters = (/ 260.,280., 0.5 /)
    optsT@InitTime = False
    optsT@lbLabelBarOn = False
    optsT@cnInfoLabelOn = False        ; turn off contour info label

    t2 = wrf_user_getvar(a,"T2",vt)
    contour_t = gsn_csm_contour(wks,t2,optsT)
    delete(optsT)

    ;;-- plot/overlay all --

    pltres = res ; Plot resources
    pltres@NoTitles = True
    pltres@MainTitlePos= False
    pltres@PanelPlot = True
    pltres@FramePlot = False
    mpres  = True  ; Map resources
    mpres@mpDataBaseVersion    = "HighRes"
    mpres@mpGeophysicalLineThicknessF = 2.0
    mpres@mpGeophysicalLineColor = "Blue"

;    plot = wrf_map_overlays(a,wks,(/contour,contour_t/),pltres,mpres)
    overlay(contour_t,contour)

;    plot(it) = wrf_map_overlays(a,wks,(/contour_t,contour/),pltres,mpres)
    plot(it) = contour_t

    delete(pltres)
    delete(mpres)

  end do

; Panelize
  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 4                ; skip every other label
  pres@gsnPanelBottom = 0.1              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@lbOrientation = "vertical"
  pres@gsnMaximize = True
  pres@gsnPanelFigureStrings = (/"a", "b", "c" ,"d"/)
  pres@amJust   = "TopLeft"


;  pres@txString         = "Integraded column Snow over SAT"
  gsn_panel(wks,plot,(/2, noft/2 /),pres)        ; create panel plot

end
;;; t2_qs_pan.ncl ends here
