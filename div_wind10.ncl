; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: wind10.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Friday, September 22 2011
; License: GPL v3 or later.
;  You should get a copy from <http://www.gnu.org/licenses/gpl.html>
;

; Description:
;

load "$nsc/yagUtils.ncl"

begin
;--------------------------------------------------------------------
; input file

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  tvalues = (/71, 82, 95, 119 /)   ;specify desired timestep outputs must be even
  out  = "div_wind"       ;out put file name
  type = "pdf"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"nrl_sirkes")            ; choose color map
;  gsn_reverse_colormap(wks)


  times  = wrf_user_list_times(a)  ; get times in the file
  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  res = True
  res = set_no_frame_res(res)
  res = set_wrf_no_headers(res)
  pltres = res
  mpres  = set_high_res_coast(res)


  do it = 0, noft - 1, 1   ; LOOP NAME
    print("tvalue: " + tvalues(it))

    print("Working on time: " + times(tvalues(it)))

    u10 = wrf_user_getvar(a,"U10",tvalues(it))   ; U component of the wind at 10m
    v10 = wrf_user_getvar(a,"V10",tvalues(it))   ; V component of the wind at 10m

    opts = res
    opts@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots
    opts = set_vc_res(opts)

    opts@FieldTitle = "Wind"       ; overwrite Field Title
    opts@vcGlyphStyle = "LineArrow"
    opts@vcGlyphStyle        = "CurlyVector"    ; turn on curly vectors
    opts@vcRefMagnitudeF = 10.

;    v_mag = sqrt(v10 ^ 2 + u10 ^ 2)


    dim=dimsizes(u10)
    dx = 1500                  ; horizontal grid distance in x direction
    div=new( (/ dim(0), dim(1) /) , typeof(u10))
    div = uv2dvG(u10,v10)
    div = div * dx

    opts_c  = set_cn_resorces(res)
    opts_c@ContourParameters = (/-.05,.1,.02/)
    opts_c@lbLabelBarOn = False
    opts_c@cnLinesOn = False
    cn = wrf_contour(a,wks,div,opts_c)

    vector = wrf_vector(a,wks,u10(:,:),v10(:,:),opts)
    plot(it) = wrf_map_overlays(a,wks,(/vector,cn/),pltres,mpres)

  end do

  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 3                ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@gsnMaximize = True

  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end
