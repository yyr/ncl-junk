import("yag_utils")

begin
  a = set_inputfile()
; GRDFLX         1  0  GROUND HEAT FLUX (W m-2)
; ACGRDFLX       1  0  ACCUMULATED GROUND HEAT FLUX (J m-2)
; HFX            1  0  UPWARD HEAT FLUX AT THE SURFACE (W m-2)
; LH             1  0  LATENT HEAT FLUX AT THE SURFACE (W m-2)
; ACHFX          1  0  ACCUMULATED UPWARD HEAT FLUX AT THE SURFACE (J m-2)
; ACLHF          1  0  ACCUMULATED UPWARD LATENT HEAT FLUX AT THE SURFACE (J m-2)
; SNOPCX         1  0  snow phase change heat flux (W m-2)
; QFX            1  0  UPWARD MOISTURE FLUX AT THE SURFACE (kg m-2 s-1)

  res = True

  var = "HFX"
  set_res_cn_limits(res,-100,700.,40)
  res@gsnLeftString = "HFX"

  ; var = "LH"
  ; set_res_cn_limits(res,-100,500.,40)
  ; res@gsnLeftString = "LH"

  ; var = "ACHFX"
  ; set_res_cn_limits(res,-10,100.,2)
  ; res@gsnLeftString = "ACHFX"

  ; var = "ACGRDFLX"
  ; set_res_cn_limits(res,-5.,10.,.5)
  ; res@gsnLeftString = "ACGRDFLX"

  ; var = "QFX"
  ; set_res_cn_limits(res,0.,.0003,.00002)
  ; res@gsnLeftString = "QFX"


  vt = 95
  type = "pdf"
  out = var + "_" + vt

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"cmp_flux")

  times  = wrf_user_list_times(a)  ; get times in the file
  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  res = set_res_lb(res)
  res = set_res_highres_coast(res)
  res = set_aspectratio(xlat,res)
  res@mpGeophysicalLineThicknessF = 3
  res@gsnMajorLatSpacing = 1
  res@gsnMajorLonSpacing = 1

  res@cnFillOn = True
  res@cnLinesOn = False
  res@gsnLeftString = ""
  ; res@gsnRightString = ""
  res = set_res_mp_latlon(res,141.,145,43,47.5)

  print("working with: "+ vt + " "+ times(vt))

  h = wrf_user_getvar(a,var,vt)
  ; h = h / 1e6
  ; h@units = "MJ m-2"

  h@lat2d = xlat
  h@lon2d = xlon

  plot = gsn_csm_contour_map(wks,h,res)
  print("" + out + "." + type)
end
;;; t2_qs_pan.ncl ends here
