import("yag_utils")

begin
  a = set_inputfile()
  lev = 0

  tvalues = (/ 73,83,91,101 /)
  out  = "div_wind"       ;out put file name
;  type = "x11"
  type = "pdf"
  thin = 18

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

  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  opts = res
  opts = set_res_vc(opts)

  do it = 0, noft - 1, 1
    vt = tvalues(it)
    print("tvalue: " + tvalues(it))
    u_1 = wrf_user_getvar(a,"ua",vt)
    v_1 = wrf_user_getvar(a,"va",vt)
    mx = wrf_user_getvar(a, "MAPFAC_M", tvalues(it))

    res = wrf_map_resources(a,res)
    date_string = chartostring(times(vt,5:15))
    delete_attrs(res)

    u = u_1(lev,:,:)
    v = v_1(lev,:,:)

    optsv = True
    optsv@vfXArray = xlon(::thin,::thin)
    optsv@vfYArray = xlat(::thin,::thin)
    optsv@gsnLeftString = ""
    optsv@gsnRightString = ""
    optsv = set_res_vc(optsv)
;    optsv@vcLineArrowColor = "white"
    optsv = set_aspectratio(xlat,optsv)
    optsv = set_res_no_frame(optsv)
    vec = gsn_csm_vector(wks,u(::thin,::thin),v(::thin,::thin),optsv)

    dim=dimsizes(u)
    div=new( (/ dim(0), dim(1) /) , typeof(u))
    div = wrf_div(u,v,dx,dy,mx)

    div@lat2d = xlat
    div@lon2d = xlon

    plot(it) = gsn_csm_contour_map(wks,div,res)
    overlay(plot(it),vec)

  end do
  pres = set_res_panel(True)
  pres@lbOrientation = "horizontal"
  pres@cnLabelBarEndStyle = "ExcludeOuterBoxes"
  panelize_2col(wks,plot,pres)
end
