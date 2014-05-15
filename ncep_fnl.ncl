load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

  lev = 700

  diri = "/home/yagnesh/DATA/FNL/20081226/"
  fnam = "fnl_20081226_12_00_c"
  grb_file = addfile(diri+fnam+".grb","r")

  x = grb_file->TMP_3_SFC(:,:) ; Read temp

  x = x-273.15 ; convert to celsius
  x@units = "C" ; update attribute

  wks = gsn_open_wks("x11","T_"+fnam) ; Open a workstation

;gsn_define_colormap(wks,"rainbow") ; Define the colormap
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; Define the colormap

  res = True ; We are using resources

  res@gsnMaximize = True ; Maximize size
  res@gsnSpreadColors = True ; Use full range of colormap
  res@cnFillOn = True ; Color plot desired
  res@cnLinesOn = False ; Turn off contour lines
  res@cnLineLabelsOn = False ; Turn off contour labels

  ; Change size and location of plot
  ; res@mpShapeMode = "FreeAspect" ; Use the free aspect shape mode
  ; res@vpYF = 0.90 ; Upper right location
  ; res@vpXF = 0.10 ; Lower left location
  ; res@vpWidthF = 0.70 ; Width of plot
  ; res@vpHeightF = 0.70 ; Height of plot

  res@mpMinLonF                     = 122.5
  res@mpMaxLonF                     = 155.5
  res@mpMinLatF                     = 27.5
  res@mpMaxLatF                     =  62.5

  res@mpFillOn = False ; Turn off map fill
  res@mpOutlineOn = True ; Turn on the outline of the map
  res@mpGeophysicalLineThicknessF = 2.0 ; Increase thickness

  res@tiMainString = lev+"hPa: "+fnam ; Establish a title
  res@mpDataBaseVersion = "MediumRes" ; Use medium resolution
  res@lbOrientation = "vertical" ; Use a vertical label bar

  plot = gsn_csm_contour_map_ce(wks, x, res) ; Plot the data

end
