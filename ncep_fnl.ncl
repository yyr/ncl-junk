import("yagUtils")

begin
  lev = 700

  diri = "/home/yagnesh/DATA/FNL/weak08_1/"
  fnam = "fnl_20080118_18_00"
  grb_file = addfile(diri+fnam+".grb","r")

  varname = "slp"

  x = grb_file->TMP_3_SFC(:,:) ; Read temp
  slp = grb_file->PRES_3_SFC

  x = x-273.15 ; convert to celsius
  x@units = "C" ; update attribute

  type = "pdf"
  out = "ncep_" + varname

  wks = gsn_open_wks(type,out) ; Open a workstation

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

  res@tiMainString = fnam ; Establish a title
  res@mpDataBaseVersion = "MediumRes" ; Use medium resolution
  res@lbOrientation = "vertical" ; Use a vertical label bar


  res = True
  res = set_res_cn(res)
  set_res_cn_limits(res, 1000, 1030,1)
  res@gsnLeftString   = "SLP" ; + "(" + varname + ")"
  res@lbLabelStride   = 3
  res@tfDoNDCOverlay = True
  res@lbTitleOn = False
  res = set_res_no_frame(res)
  res = set_res_highres_coast(res)

  res@mpFillOn = False ; Turn off map fill
  res@mpOutlineOn = True ; Turn on the outline of the map

  res@mpMinLonF                     = 122.5
  res@mpMaxLonF                     = 155.5
  res@mpMinLatF                     = 27.5
  res@mpMaxLatF                     =  62.5

  slp = slp/100.
  printVarInfo(slp,"")
  plot = gsn_csm_contour_map_ce(wks, slp, res) ; Plot the data
  draw(wks)
  frame(wks)

end
