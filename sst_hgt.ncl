import("yag_utils")
begin
  a = set_inputfile()
  wks = gsn_open_wks("png","sst_hgt")

  sst = a->SST(0,:,:)
  hgt = a->HGT(0,:,:)
  land = a->LANDMASK(0,:,:)

  land = where(land.eq.0,1,0)
  sst = sst * land

  lat_wrf = a->XLAT(0,:,:)
  lon_wrf = a->XLONG(0,:,:)

  hres = set_res_no_frame(True)
;  hres = set_res_cn(hres)
  hres = set_res_lb(hres)
  hres = set_res_highres_coast(hres)

  hres@gsnPaperMargin = 1.
  hres@gsnAddCyclic = False
  hres@gsnLeftString = ""
  hres@gsnRightString = ""

  hres@sfXArray = lon_wrf
  hres@sfYArray = lat_wrf

  hres = wrf_map_resources(a,hres)
  hres@mpGridLineColor       =  1       ; Turn off grid lat/lon lines
  hres@mpGridAndLimbOn       =  True
  hres@pmLabelBarHeightF = 0.1

  res = hres
  res@cnFillon = False
  res@mpLandFillColor = "transparent"
  set_res_cn_limits(res,273,285,1)

  hres@cnLevelSelectionMode = "ExplicitLevels"
  hres@cnLevels = (/1.,100.,200.,400.,800.,1600.,2400./)


  hres@tiMainString = "SST and Terrain"
  plot = gsn_csm_contour_map_overlay(wks,hgt,sst, hres, res)

  draw(wks)
  frame(wks)

end
