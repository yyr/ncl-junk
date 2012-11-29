; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: slp_pan.ncl
; Created: Friday, September  9 2011
; License: GPL v3 or later.
;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  tvalues = (/ 48,55,62,70,85,95 /)   ;specify desired timestep outputs must be even

  out = "slp_pan"       ;out put file name
  type = "ps"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"helix1")   ; overwrite the .hluresfile color map
  gsn_reverse_colormap(wks)

  res = True
  res@Footer = False
  res@lbLabelBarOn        = False           ; turn off individual cb's

  mpres  = True  ; Map resources
  pltres = True ; Plot resources
  mpres@mpDataBaseVersion    = "HighRes"
  mpres@mpGeophysicalLineThicknessF = 2.0

  times  = wrf_user_list_times(a)  ; get times in the file

  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 0, noft - 1, 1   ; LOOP NAME
    print("tvalue: " + tvalues(it))

    print("Working on time: " + times(it) )
    res@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots

    slp = wrf_user_getvar(a,"slp",tvalues(it))

    res@gsnDraw              = False              ; Do not draw plot
    res@gsnFrame             = False              ; Do not advance frame
    res@cnInfoLabelOn = False        ; turn off contour info label

    opts = res
    opts@cnFillOn         = True
    opts@cnFillColor = True
    opts@ContourParameters = (/ 972., 996., 1 /)
    opts@InitTime = False

    pltres@NoTitles = True
    pltres@PanelPlot = True
    pltres@FramePlot = False

    contour = wrf_contour(a,wks,slp,opts)
    plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
    delete(contour)

  end do

  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 12         ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar

  pres@txString         = "sea level pressure"      ; add common title
  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end
