;    File: wind10.ncl
import("yagUtils")

begin
  a = set_inputfile()
  lev = 0

  tvalues = (/71, 82, 95, 119 /)
  out  = "div_wind"       ;out put file name
  type = "pdf"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"mine")
  gsn_reverse_colormap(wks)
  times  = wrf_user_list_times(a)  ; get times in the file

  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  dx        = a@DX
  dy        = a@DY

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

  pltres = True
  pltres@PanelPlot = True

  res = True
  res = set_res_no_frame(res)
  res@NoHeaderFooter = True

  opts_c = res
  opts_c = set_res_no_frame(opts_c)
  opts_c  = set_res_cn(opts_c)
  opts_c@lbLabelBarOn = False
  opts_c@cnLinesOn = False
  set_res_cn_limits(opts_c,-.005,.005,.0005)

  opts = res
  opts = set_res_vc(opts)

  do it = 0, noft - 1, 1
    print("Working with time: " + times(tvalues(it)) + ", T is: " + tvalues(it))
    u_1 = wrf_user_getvar(a, "ua", tvalues(it))
    v_1 = wrf_user_getvar(a, "va", tvalues(it))
    mx = wrf_user_getvar(a, "MAPFAC_M", tvalues(it))

    u = u_1(lev,:,:)
    v = v_1(lev,:,:)

    dim=dimsizes(u)
    div=new( (/ dim(0), dim(1) /) , typeof(u))
    div = wrf_div(u,v,dx,dy,mx)

    cn = wrf_contour(a,wks,div(y_start:y_end,x_start:x_end),opts_c)
    vector = wrf_vector(a,wks,u(y_start:y_end,x_start:x_end),v(y_start:y_end,x_start:x_end),opts)
    plot(it) = wrf_map_overlays(a,wks,(/cn,vector/),pltres,mpres)

  end do
  pres = set_res_panel(True)
  pres@lbOrientation = "horizontal"
  pres@cnLabelBarEndStyle = "ExcludeOuterBoxes"
;  gsn_panel(wks,plot,(/1,1/),pres)
  panelize_2col(wks,plot,pres)
end
