load "$nsc/yagUtils.ncl"
begin
  a = set_inputfile()
  wks = gsn_open_wks("png","domain")

  sst = a->SST(0,:,:)
  hgt = a->HGT(0,:,:)

  lat_wrf = a->XLAT(0,:,:)
  lon_wrf = a->XLONG(0,:,:)

  hres = set_res_no_frame(True)
  hres = set_res_cn(hres)
  hres = set_res_highres_coast(hres)
  hres = set_res_lb(hres)

  hres@gsnPaperMargin = 1.
  hres@gsnAddCyclic = False
  hres@gsnLeftString = ""
  hres@gsnRightString = ""

  hres@sfXArray = lon_wrf
  hres@sfYArray = lat_wrf


  hres@cnLevelSelectionMode = "ExplicitLevels"
  hres@cnLevels = (/0.,1.,100.,200.,400.,800.,1600.,2400./)

  hres = wrf_map_resources(a,hres)
  hres@mpGridLineColor       =  1       ; Turn off grid lat/lon lines
  hres@mpGridAndLimbOn       =  True
  hres@pmLabelBarHeightF = 0.1

  hres@tiMainString = "Model Domain"
  plot = gsn_csm_contour_map(wks, hgt, hres)

  draw(wks)
  frame(wks)

end
