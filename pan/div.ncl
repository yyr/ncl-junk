import("yag_utils")

begin
  a = set_inputfile()
  lev = 0

  tvalues = (/ 60,82,100,120 /)
  out  = "div_wind"       ;out put file name
;  type = "x11"
  type = "pdf"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"mine")
  gsn_reverse_colormap(wks)
  times = a->Times
  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  res = True
  res = set_res_cn(res)
  res = set_res_no_frame(res)
  res = set_res_highres_coast(res)
  res@tfDoNDCOverlay = True
  res@lbTitleOn = False
  set_res_cn_limits(res,-.005,.005,.0005)
  false(res,"lbLabelBarOn")

  dx        = a@DX
  dy        = a@DY

  ; lats = (/ 44., 47.0 /)
  ; lons = (/ 142., 145.5 /)
  ; loc = wrf_user_ll_to_ij(a, lons, lats, True)

  ; x_start = loc(0,0) - 1
  ; x_end   = loc(0,1) - 1
  ; y_start = loc(1,0) - 1
  ; y_end   = loc(1,1) - 1

  ; mpres = True
  ; mpres@ZoomIn = True
  ; mpres@Xstart = x_start
  ; mpres@Ystart = y_start
  ; mpres@Xend = x_end
  ; mpres@Yend = y_end


  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  opts = res
  opts = set_res_vc(opts)

  do it = 0, noft - 1, 1
    vt = tvalues(it)
    print("tvalue: " + tvalues(it))
    u_1 = wrf_user_getvar(a, "ua", tvalues(it))
    v_1 = wrf_user_getvar(a, "va", tvalues(it))
    mx = wrf_user_getvar(a, "MAPFAC_M", tvalues(it))

    res = wrf_map_resources(a,res)
;    res = set_lb_resources(div,res)
    date_string = chartostring(times(vt,5:15))
    delete_attrs(res)

    u = u_1(lev,:,:)
    v = v_1(lev,:,:)

    dim=dimsizes(u)
    div=new( (/ dim(0), dim(1) /) , typeof(u))
    div = wrf_div(u,v,dx,dy,mx)

    div@lat2d = xlat
    div@lon2d = xlon

    ; cn = wrf_contour(a,wks,div(y_start:y_end,x_start:x_end),opts_c)
    ; vector = wrf_vector(a,wks,u(y_start:y_end,x_start:x_end),v(y_start:y_end,x_start:x_end),opts)
    plot(it) = gsn_csm_contour_map(wks,div,res)

  end do
  pres = set_res_panel(True)
  pres@lbOrientation = "horizontal"
  pres@cnLabelBarEndStyle = "ExcludeOuterBoxes"
  panelize_2col(wks,plot,pres)
end
