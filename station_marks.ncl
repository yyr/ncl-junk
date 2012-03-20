
; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: station_marks.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Tuesday, December 20 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
; put marks on certain places

load "$nsc/yagUtils.ncl"

begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

; We generate plots, but what kind do we prefer?
  type = "x11"
  out = "station_marks"
  wks = gsn_open_wks(type,out)

; Set some basic resources
  res = True

  pltres = True
  mpres  = True


; Set some basic resources



  xLat     = a->XLAT(0,:,0)
  xLong    = a->XLONG(0,0,:)
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  st1 = (/125,124/)
  st2 = (/145,129/)

    height  =  wrf_user_getvar(a,"height",0)
    terrain =  wrf_user_getvar(a,"ter",0)

  ;;;;;;;;;;;;;;;; HIGHRES RANGS/GSHHS COASTLINE PLOT RESOURCES ;;;;;;;;;;;;;;;;;;;;;;;;

  wrf_mapres_c(a, mpres, 0)

  mpres@gsnMaximize           = True
  mpres@mpOutlineOn           = True
  mpres@mpFillOn              = False
  mpres@mpGridLineColor       = "Gray"
  mpres@mpGridLineThicknessF  = 0.5
  mpres@mpGridpacingF         =  3
  mpres@gsnDraw               = False             ; don't draw the plots
  mpres@gsnFrame              = False             ; don't advance the frame
  mpres@tmYROn                = False
  mpres@tmXTOn                = False
  mpres@mpGeophysicalLineColor= "Black"
  mpres@mpLimbLineColor       = "Blue"
  mpres@mpGeophysicalLineThicknessF = 1.6
  mpres@mpDataBaseVersion     = "HighRes"    ; Use the high-res database
  mpres@mpDataResolution      = "FinestResolution"
  mpres@pmTickMarkDisplayMode = "Always"     ; Turn on map tickmarks.
  map = gsn_csm_map(wks,mpres)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


   gsn_define_colormap(wks,"OceanLakeLandSnow")


   opts = res
   opts@cnHighLabelsOn                  = False
   opts@cnLowLabelsOn                   = False
   opts@cnConstFLabelPerimOn            = False
   opts@cnConstFLabelOn                 = False
   opts@cnInfoLabelPerimOn              = False

   opts@cnLevelSelectionMode = "ExplicitLevels"

   opts@cnLevels       = (/0.001, 3, 6, 10, 15, 20, 25, 30, 40, 50, 60, 70, 80, 90, 100, 120, 140, 160, 180, \
                          200, 230, 260, 290, 320, 350, 380, 410, 440, 470, 500, 530, 560, 590, 620, 650,  \                       \
                          680, 710,  740, 770, 800, 840, 880, 920, 960, 1000, 1150, 1200, 1250, 1300, 1350,  \
 1400, 1450, 1500, 1550, 1600, 1650, 1700, 1750, 1800, 1850, 1900, 1950, 2000,    \
 2100, 2200, 2300, 2400, 2500, 2600, 2700, 2800, 2900, 3000, 3100, 3200, 3300/)
; Set some contouring resources.

  opts@gsnMaximize     = True    ; Maximize plot in frame

  opts@cnInfoLabelOn   = False   ; Turn off annotations

; Set contour resources
  opts@cnLinesOn       = False
  opts@cnLineLabelsOn  = False
  opts@cnInfoLabelOn   = False

  opts@cnFillOn        = True
  opts@cnFillMode      = "AreaFill"    ; This is the default.
  opts@lbOrientation   = "Horizontal"

; Set contour levels.
      contour_terC = wrf_contour(a,wks,terrain,opts)
      delete(opts)

 ; plot Markers at station locations

  lat       = (/33.883,33.367,34.983, 31.617, 35.583, 35.733, 34.050, 33.933, 33.567, 30.933/)        ; Latitudes of station locations
lon       = (/-5.533,-7.583, -3.017, -8.032 , -5.333 ,-5.900, -6.767,  -4.983, -7.667, -6.900/)              ; longitudes of station locations
stn_elev  = (/560,   206,   175,    466,     10,     21,     79,       579,    57,     1140/)                                  ; elevation asl of station
stn_names = (/"Meknes","Nouasseur","Arwi","Marrakech","Tetouan","Tanger-AER","Rabat-Sale","Fes-Sais","Casablanca","Ouarzazate"/)
gsres               = True
        gsres@gsMarkerIndex = 16          ; Use filled dots for markers.
gsres@gsMarkerColor      = "Black"
        gsres@gsMarkerThicknessF = 0.9
        gsres@PanelPlot = True
gsres@FramePlot = False
nStn = dimsizes(lat)
        plot_Stn = gsn_add_polymarker(wks,map,lon(0:nStn-1),lat(0:nStn-1), gsres)

  ;      draw(map)


   ; MAKE PLOTS
      plot = wrf_map_overlays(a,wks,(/contour_terC, plot_Stn/), pltres, mpres)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



  frame(wks)

end


;;; station_marks.ncl ends here
