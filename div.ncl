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

  dim = dimsizes(u)
  div = new( (/ dim(0), dim(1) /) , typeof(u))
  div = wrf_div(u,v,dx,dy,msft)

  wks = gsn_open_wks("ps","div")

  lats = (/ 44., 47.0 /)
  lons = (/ 142., 145.5 /)
  loc = wrf_user_ll_to_ij(a, lons, lats, True)

  x_start = loc(0,0) - 1
  x_end   = loc(0,1) - 1
  y_start = loc(1,0) - 1
  y_end   = loc(1,1) - 1

  mpres = True
  mpres@ZoomIn = True
  mpres@Xstart = x_start
  mpres@Ystart = y_start
  mpres@Xend = x_end
  mpres@Yend = y_end
  mpres = set_res_highres_coast(mpres)

  opts = True
  opts = set_res_cn(opts)
  opts@gsnFrame = False
  set_res_cn_limits(opts,-.005,.005,.0005)
  cn = wrf_contour(a,wks,div(y_start:y_end,x_start:x_end),opts)

  res = True
  res = set_res_vc(res)
  vec = wrf_vector(a,wks,u(y_start:y_end,x_start:x_end),v(y_start:y_end,x_start:x_end),res)
  mn = wrf_map_overlays(a,wks,(/cn,vec /),opts,mpres)

end
