load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin


  DATADir = "."

  Files = systemfunc (" ls -1 " + DATADir + "wrfout_d01_2008-07-* ")
  print(Files)

; type = "x11"
  type = "pdf"
; type = "ps"
; type = "ncgm"
  res = True
  res@MainTitle = "REAL-TIME WRF"
  wks = gsn_open_wks(type,"KF2TotalNewPrecip")
  gsn_define_colormap(wks,"WhViBlGrYeOrReWh")




; Set some basic resources
;res@lbLabelFontHeightF =.025 ; make labels larger
;res@lbTitleFontHeightF =.015 ; makes label tiles larger..
; res@tmXBFontHeightF =0.025

  pltres = True
  mpres = True
  mpres@mpGeophysicalLineColor = "Black"
  mpres@mpNationalLineColor = "Black"
  mpres@mpUSStateLineColor = "Black"
  mpres@mpGridLineColor = "Black"
  mpres@mpLimbLineColor = "Black"
  mpres@mpPerimLineColor = "Black"
  mpres@mpGridSpacingF = 1000
  mpres@mpDataBaseVersion = "MediumRes" ; Alias 'Ncarg4_1'
  mpres@mpDataSetName = "Earth..4"
  mpres@mpOutlineOn = True ; Turn on map outlines
  mpres@mpOutlineSpecifiers = (/"Canada:provinces"/)
  opts = res
  opts@cnFillOn = True




  ntimes = dimsizes(Files) ; number of times in the file

  times = new(ntimes,string)
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

;  a = addfile(Files(0)+".nc","r")
  times(0) = wrf_user_list_times(a) ; get times in the file
  mpres@mpDataBaseVersion = "Ncarg4_1" ; higher res data base
  if (a@GRID_ID .ge. 3) then
    mpres@mpDataBaseVersion = "HighRes"
  end if



  do it = 1,ntimes-1,1
;    a = addfile(Files(it)+".nc","r")
;    a_last = addfile(Files(it-1)+".nc","r")
    ff = floattointeger(a->XTIME/60.)
    PlotName = "pp_d0*_"+sprinti("%0.2i",ff)
    print("PlotName: "+PlotName)


    times(it) = wrf_user_list_times(a) ; get times in the file
    print("Working on time: " + times(0) )
    res@TimeLabel = times(it) ; Set Valid time to use on plots

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; First get the variables we will need


    rain_exp = a->RAINNC(0,:,:)

    rain_con = a->RAINC(0,:,:)

    rain_exp = rain_exp - a_last->RAINNC(0,:,:)
    rain_con = rain_con - a_last->RAINC(0,:,:)
    rain_tot = rain_exp + rain_con

    rain_tot@description = "Total Precipitation"



; Plotting options for Precipitation
    opts_r = res
    opts_r@UnitLabel = "mm"
    opts_r@cnLevelSelectionMode = "ExplicitLevels"
    opts_r@cnLevels = (/ .1, 1, 2, 4, 8, 12, 18, \
    24, 37, 50, 75, 100, 150, 200/)
    opts_r@cnInfoLabelOn = False
    opts_r@cnConstFLabelOn = False
    opts_r@cnFillOn = True



    opts_r@SubFieldTitle = "from " + times(it-1) + " to " + times(it)

; MAKE PLOTS

    contour_tot = wrf_contour(a,wks, rain_tot,opts_r) ; total (color)
    contour_con = wrf_contour(a,wks, rain_con,opts_r) ; total (color)
    contour_exp = wrf_contour(a,wks, rain_exp,opts_r) ; total (color)


    plot = wrf_map_overlays(a,wks,(/contour_con/),pltres,mpres)
    plot = wrf_map_overlays(a,wks,(/contour_exp/),pltres,mpres)
    plot = wrf_map_overlays(a,wks,(/contour_tot/),pltres,mpres)

    delete(a)
    delete(a_last)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  end do ; END OF TIME LOOP

end
