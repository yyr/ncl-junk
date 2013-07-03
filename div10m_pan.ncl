;    File: wind10.ncl
load "$nsc/yagUtils.ncl"

begin
  a = set_inputfile()
;  tvalues = (/71/)
  tvalues = (/71, 82, 95, 119 /)
  out  = "div_wind"       ;out put file name
  type = "pdf"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"mine")
  gsn_reverse_colormap(wks)
  times  = wrf_user_list_times(a)  ; get times in the file

  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  res = True
  res = set_no_frame_res(res)
  res@tfDoNDCOverlay = True

  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  dx        = a@DX
  dy        = a@DY

  do it = 0, noft - 1, 1
    print("Working with time: " + times(tvalues(it)) + ", T is: " + tvalues(it))
    u10 = wrf_user_getvar(a,"U10",tvalues(it))
    v10 = wrf_user_getvar(a,"V10",tvalues(it))
    mx = wrf_user_getvar(a,"MAPFAC_M",10)

    dim=dimsizes(u10)
    div=new( (/ dim(0), dim(1) /) , typeof(u10))
    div = wrf_div(u10,v10,dx,dy,mx)

    opts_c = res
    opts_c  = set_cn_resorces(opts_c)
    opts_c  = set_high_res_coast(opts_c)
    opts_c = set_map_latlon_res(opts_c,142.,145.5,44.,47.)
    opts_c = set_aspectratio(div,opts_c)
    opts_c@gsnLeftString = ""

    set_cn_limits(opts_c,-.005,.005,.0005)

    opts_c@lbLabelBarOn = False
    opts_c@cnLinesOn = False
    cn = gsn_csm_contour_map(wks,div,opts_c)

    opts = True
    opts = set_no_frame_res(res)
    opts = set_vc_res(opts)
    opts = set_aspectratio(div,opts)
    opts@gsnLeftString = ""
    opts@gsnRightString = ""
    vector = gsn_csm_vector(wks,u10,v10,opts)

    overlay(cn,vector)
    plot(it) = cn
  end do
  pres = set_panel_resources(True)
  pres@lbOrientation = "horizontal"
  pres@cnLabelBarEndStyle = "ExcludeOuterBoxes"
;  gsn_panel(wks,plot,(/1,1/),pres)
  panelize_2col(wks,plot,pres)
end
