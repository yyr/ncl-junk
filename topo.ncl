;************************************************
; commonly loaded
;************************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin
;************************************************
; open netCDF file: read in selected variables
;************************************************
  din = "~/DATA/terrain/"
  fin = "ETOPO1_Ice_g_gmt4.grd"
  ;; f = addfile(diri+fili,"r")
  f = addfile(din + fin + ".nc","r")

  xr = f->x_range
  yr = f->y_range
  zr = f->z
  ival = f->spacing


  resolution = 1                      ; one minu

  xpts= 21601
  ypts = 10

  lat           = new(xpts,"float")
  lat!0         = "lat"
  lat&lat       = fspan(-90,90,xpts)
  lat@long_name = "latitude"
  lat@units     = "degrees_north"

  lon           = new(ypts,"float")
  lon!0          = "lon"
  lon&lon        = fspan(0,360,ypts)
  lon@long_name  = "longitude"
  lon@units      = "degrees_east"

  data     = new((/xpts,ypts/),"double")  ; (lat,lon)
  data!0   = "lat"
  data&lat = lat
  data!1   = "lon"
  data&lon = lon
  data(:,:)    = onedtond(zr,(/xpts,ypts/))
;  data@_FillValue = f@_FillValue ; Set t's _FillValue to global _FillValue



;************************************************
; open graphic wkstation
;************************************************
  wks = gsn_open_wks("x11","topo")

;************************************************
; plot options (NCL refers to these as resources)
;************************************************
  res = True ; options desired
  ;; res@gsnAddCyclic = False
  ;; res@gsnMaximize = True ; maximize size of plot

  ;; res@tiMainString = "North Sea Bathymetry (curvi)"
  ;; res@mpFillDrawOrder = "PostDraw"
  ;; ;; res@mpMinLatF = min(lat2d) ; zoom in on map
  ;; ;; res@mpMaxLatF = max(lat2d)
  ;; ;; res@mpMinLonF = min(lon2d)
  ;; ;; res@mpMaxLonF = max(lon2d)

  ;; res@cnFillOn = True
  ;; res@cnRasterModeOn = True
  ;; res@cnLinesOn = False
  ;; res@cnLineLabelsOn = False

  ;; res@cnLevelSelectionMode = "ManualLevels"
  ;; res@cnMinLevelValF = 0.
  ;; res@cnMaxLevelValF = 400.
  ;; res@cnLevelSpacingF = 25.

  ;; res@lbLabelStride = 2 ; Only label every other label box.

  plot = gsn_csm_contour_map_ce(wks,data,res) ; Draw a contour plot.


end
