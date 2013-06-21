;;    File: div.ncl
load "$nsc/yagUtils.ncl"
begin

  a = set_inputfile()

  u = wrf_user_getvar(a,"U10",95)
  v = wrf_user_getvar(a,"V10",95)
  msft = wrf_user_getvar(a,"MAPFAC_M",1)
  mu = wrf_user_getvar(a,"MAPFAC_U",1)
  mv = wrf_user_getvar(a,"MAPFAC_V",1)

  dx        = a@DX
  dy        = a@DY
  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  dim = dimsizes(u)
  div = new( (/ dim(0), dim(1) /) , typeof(u))

  div = wrf_div(u,v,dx,dy,msft)
  div2 = wrf_div2(u,v,dx,dy,msft,mu,mv)

  wks = gsn_open_wks("ps","div")
  wks2 = gsn_open_wks("ps","div2")

  opts = True
  ; opts@tfDoNDCOverlay = "NDCViewport"
  opts = set_cn_resorces(opts)
  opts@gsnSpreadColors = True    ;spread Colors

  opts@gsnAddCyclic = False
  opts@sfYArray = xlon
  opts@sfXArray = xlat

;  opts@ContourParameters = (/-.02,.02,.002/)
  opts = wrf_map_resources(a,opts)
  delete_attrs(opts)
  print(opts)

  cn = gsn_csm_contour_map(wks,div,opts)
  cn2 = wrf_contour(a,wks2,div2,opts)
  cn2 = wrf_overlays(a,wks2,(/div2/),opts)
end
