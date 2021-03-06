;    File: wind10.ncl
;  Author: Yagnesh Raghava Yakkala <hi@yagnesh.org>
; Created: Friday, September 22 2011

; Description:
;

import("yag_utils")

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  tvalues = (/71, 82, 95, 119 /)   ;specify desired timestep outputs must be even
  ; type = "x11"
  type = "pdf"
  out  = "wind10"       ;out put file name

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"WhiteYellowOrangeRed")            ; choose color map

  res = True
  res = set_res_no_frame(res)
  res = set_res_no_frame(res)
  res = set_res_wrf_no_headers(res)

  mpres  = res
  pltres = res
  mpres@mpDataBaseVersion    = "HighRes"
  mpres@mpGeophysicalLineThicknessF = 2.0
  mpres@mpGeophysicalLineColor = "Blue"

  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 0, noft - 1, 1   ; LOOP NAME
    print("tvalue: " + tvalues(it))

    print("Working on time: " + times(tvalues(it)))
    res@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots
    ; res@gsnLeftString = times(tvalues(it))   ; Set Valid time to use on plots

    u10 = wrf_user_getvar(a,"U10",tvalues(it))   ; U component of the wind at 10m
    v10 = wrf_user_getvar(a,"V10",tvalues(it))   ; V component of the wind at 10m

    opts = res
    opts = set_res_vc(opts)

    opts@FieldTitle = "Wind"       ; overwrite Field Title
    opts@vcGlyphStyle = "LineArrow"
    opts@vcGlyphStyle        = "CurlyVector"    ; turn on curly vectors
    opts@vcRefMagnitudeF = 10.

    opts_c  = set_res_cn(res)
    opts_c@cnLevels = fspan(2.,20.,18)
    opts_c@cnLinesOn = False

    v_mag = sqrt(v10 ^ 2 + u10 ^ 2)
;    cn = wrf_contour(a,wks,v_mag,opts_c)

    vector = wrf_vector(a,wks,u10(:,:),v10(:,:),opts)
    print("I came here")
    plot(it) = wrf_map_overlays(a,wks,(/vector/),pltres,mpres)

  end do

  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 6                ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@gsnMaximize = True

  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end
