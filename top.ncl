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

  x = f->x
  y = f->y
  z = f->z

  y@units = "degrees_north"
  x@units = "degrees_east"

  z!0 = "lat"
  z&lat = y

  z!1 = "lon"
  z&lon = x

  wks = gsn_open_wks("x11","topo")
;  gsn_define_colormap(wks,"BlueRedGray")   ; overwrite the .hluresfile color map


  res = True

  res@gsnAddCyclic = False
  ;; res@gsnMaximize = True ; maximize size of plot

  res@cnFillOn = True
  res@cnLinesOn = False
  res@cnLineLabelsOn = False

  res@tiMainString = "North Sea Bathymetry (curvi)"
  ;; res@mpFillDrawOrder = "PostDraw"
  res@mpMinLatF = 35.
  res@mpMaxLatF = 55.
  res@mpMinLonF = 125.
  res@mpMaxLonF = 155.

  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF = 0.
  res@cnMaxLevelValF = 1000.
  res@cnLevelSpacingF = 200.
  res@gsnSpreadColors = True

  plot = gsn_csm_contour_map_ce(wks,z,res)

end
