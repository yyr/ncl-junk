
; First let's just get and plot t2 at a point
; Add some inrfto to the plot
; Add slp to the plot
; Add a time-Z plot above slp and t2
; Use wrf_user_ll_to_ij to get the point of interest
; Clean up the plot


;***********************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;***********************************************
begin
;***********************************************

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

;-----------------------------------------------------------------------

; Find the ij location for the point if interest
  ;; land point over hokkaido
  ;; lat = 43.25
  ;; lon = 143.

  ;; land point over hokkaido
  lat = 45.5
  lon = 143.

  llres = True
  llres@ReturnInt = True   ; Return integer values
  locij = wrf_user_ll_to_ij(a, lon, lat, llres)
  locij = locij - 1        ; array pointers in NCL space
  locX = 179
 locY = 71
 wks = gsn_open_wks("ps","meteo_land")    ; open a workstation

  ;; locY = 119
  ;; wks = gsn_open_wks("ps","meteo_sea")    ; open a workstation

;  print(locij)

  taus =  ispan(47,96,4)      ; create a time reference

; get time information and strip out the day and hour
  times_in_file = a->Times
  dims = dimsizes(times_in_file)
  times = new(dims(0),string)

  do i=0,dims(0)-1
    times(i) = chartostring(times_in_file(i,8:12))
  end do


;-----------------------------------------------------------------------

  t2    = wrf_user_getvar(a,"T2",-1)    ; get t2 for all times
  slp   = wrf_user_getvar(a,"slp",-1)   ; get slp for all times

  tc    = wrf_user_getvar(a,"tc",-1)    ; get tc for all times
  uvmet = wrf_user_getvar(a,"uvmet",-1) ; get rotated u and v comp of wind

  print("I came here ----")

;-----------------------------------------------------------------------

  t2_point  = t2(taus,locY,locX)           ; extract a time series at a point
  slp_point = slp(taus,locY,locX)
  tc_point  = tc(taus,:,locY,locX)

  u_point   = uvmet(0,taus,:,locY,locX)
  v_point   = uvmet(1,taus,:,locY,locX)
  print("I came here 2")

; Swap the dimensions as we want to plot time on the X axis later
  tt        = tc_point(bottom_top|:,Time|:)
  ugrid     = u_point(bottom_top|:,Time|:)
  vgrid     = v_point(bottom_top|:,Time|:)
  print("I came here 3")

;-----------------------------------------------------------------------

  res2D = True                            ; Set basic resources
  res2D@gsnDraw              = False      ; Don't draw individual plot.
  res2D@gsnFrame             = False      ; Don't advance frame.
  res2D@vpXF                 = 0.15       ; x location
  res2D@vpYF                 = 0.90       ; y location
  res2D@vpWidthF             = 0.70       ; width
  res2D@vpHeightF            = 0.40       ; height
  res2D@tiXAxisString        = "Day_Time"
  res2D@tiXAxisFontHeightF   = 0.016
  res2D@tmXBMode             = "Explicit"
  res2D@tmXBValues           = taus
  res2D@tmXBLabels           = times(taus)
  res2D@tmXBLabelJust        = "CenterCenter"
  res2D@tmXBLabelFontHeightF = .012

  tt_res = res2D
  tt_res@sfXArray                 = taus
  tt_res@gsnSpreadColors          = True             ; use full range of colors
  tt_res@cnFillOn                 = True             ; turns on color fill
  tt_res@cnLevelSelectionMode     = "ManualLevels"   ; set levels manually
  tt_res@cnMinLevelValF           = -60.
  tt_res@cnMaxLevelValF           = 5.
  tt_res@cnLevelSpacingF          = 0.5
  tt_res@cnLinesOn                = False
  tt_res@cnLineLabelsOn           = False
  tt_res@cnInfoLabelOn            = False
  tt_res@pmLabelBarDisplayMode    = "Always"         ; Add a label bar
  tt_res@pmLabelBarSide           = "Bottom"
  tt_res@pmLabelBarOrthogonalPosF = -0.15
  tt_res@pmLabelBarParallelPosF   = 0.44
  tt_res@lbAutoManage             = False
  tt_res@lbLabelAutoStride        = True
  tt_res@lbOrientation            = "Horizontal"
  tt_res@lbPerimOn                = False
  tt_res@lbJustification          = "BottomLeft"
  tt_res@lbBoxMinorExtentF        = 0.13
  tt_res@lbLabelFontHeightF       = 0.012
  tt_res@lbBoxLinesOn             = False
  tt_res@tiMainString             = "Meteogram over Hokkaido"


  uv_res = res2D
  uv_res@vfXArray         = taus
  uv_res@vcRefAnnoOn      = False         ; turns off the ref vector
  uv_res@vcRefLengthF     = 0.040         ; set length of ref vector
  uv_res@vcGlyphStyle     = "WindBarb"    ; turn on wind barbs


;-----------------------------------------------------------------------

  res1D = True                            ; Set basic resources both will use
  res1D@vpXF              = 0.15          ; The left side of the box location
  res1D@vpWidthF          = 0.70          ; The Width of the plot box
  res1D@vpHeightF         = 0.10          ; The height of the plot box
  res1D@tmXBMode          = "Explicit"    ; Define own tick mark labels.
  res1D@tmXBValues        = taus          ; location of explicit labels
  res1D@tmXBLabels        = times(taus)         ; labels are the locations
  res1D@tmXTOn            = False         ; turn off the top tick marks
  res1D@xyLineThicknesses = 2             ; increase line thickness
  res1D@gsnDraw           = False         ; Don't draw individual plot.
  res1D@gsnFrame          = False         ; Don't advance frame.


  slp_res = res1D
  slp_res@vpYF            = 0.35          ; The top side of the plot box loc
  slp_res@xyLineColor     = "red"         ; set line color
  slp_res@tiYAxisString   = "PMSL"        ; set y-axis string


  t2_res = res1D
  t2_res@vpYF             = 0.20          ; The top side of the plot box loc
  t2_res@xyLineColor      = "blue"        ; set line color

;-----------------------------------------------------------------------

  ttfill    = gsn_contour(wks,tt,tt_res)
  windlayer = gsn_vector(wks,ugrid,vgrid,uv_res)
  overlay(ttfill,windlayer)

  slp_plot  = gsn_csm_xy(wks,taus,slp_point,slp_res)
  t2_plot  = gsn_csm_xy(wks,taus,t2_point,t2_res)

  draw(ttfill)
  draw(slp_plot)
  draw(t2_plot)

  frame(wks)                            ; now frame the plot

;-----------------------------------------------------------------------

end
