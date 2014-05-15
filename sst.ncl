;; Created: Friday, September  9 2011
load "$nsc/yagUtils.ncl"

begin
  a = set_inputfile()

  type = "pdf"

  wks = gsn_open_wks(type,"sst")
  gsn_define_colormap(wks,"WhBlGrYeRe")   ; overwrite the .hluresfile color map

  res = True

  mpres  = True  ; Map resources
  pltres = True ; Plot resources
  mpres@mpDataBaseVersion    = "HighRes"
  mpres@mpGeophysicalLineThicknessF = 2.0
  mpres@gsnMaximize = True

  sst = wrf_user_getvar(a,"SST",0)
  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  sst@lat2d = xlat
  sst@lon2d = xlon

  opts = res
  opts@cnFillOn         = True
  opts@ContourParameters = (/ 270.,285., .5 /)
  opts@cnFillColor = True
  pltres@NoTitles = True

  contour = wrf_contour(a,wks,sst,opts)
  plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
  delete(contour)

end
