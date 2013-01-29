;;    File: panel_t.ncl
;;  Author: Yagnesh Raghava Yakkala <hi@yagnesh.org>
;; Created: Friday, September  9 2011
;;

load "$nsc/yagUtils.ncl"

begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

  ;; type = "x11"
  type = "ps"

  wks = gsn_open_wks(type,"sst")
  gsn_define_colormap(wks,"WhBlGrYeRe")   ; overwrite the .hluresfile color map

  res = True
  res@Title = False
  res@MainTitle = "Sea Surface Temepature SST"
  res@Footer = False

  mpres  = True  ; Map resources
  pltres = True ; Plot resources
  mpres@mpDataBaseVersion    = "HighRes"
  mpres@mpGeophysicalLineThicknessF = 2.0
  mpres@gsnMaximize = True

  ;; times  = wrf_user_list_times(a)  ; get times in the file
  ;; ntimes = dimsizes(times)         ; number of times in the file

  sst = wrf_user_getvar(a,"SST",0)

  opts = res
  opts@cnFillOn         = True
  opts@ContourParameters = (/ 270.,285., .5 /)
  opts@cnFillColor = True
  pltres@NoTitles = True

  contour = wrf_contour(a,wks,sst,opts)
  plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
  delete(contour)

end
