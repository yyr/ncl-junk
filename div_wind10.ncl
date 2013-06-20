;    File: wind10.ncl

load "$nsc/yagUtils.ncl"

begin
  a = set_inputfile()
  tvalues = (/71, 82, 95, 119 /)
  out  = "div_wind"       ;out put file name
  type = "pdf"

  wks = gsn_open_wks(type,out)
  times  = wrf_user_list_times(a)  ; get times in the file

  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  res = True
  res = set_no_frame_res(res)
  res@gsnAddCyclic = False

  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)
  res@sfYArray = xlat
  res@sfXArray = xlon

  dx        = a@DX
  dy        = a@DY

  do it = 0, noft - 1, 1
    print("Working with time: " + times(tvalues(it)) + ", T is: " + tvalues(it))
    u10 = wrf_user_getvar(a,"U10",tvalues(it))
    v10 = wrf_user_getvar(a,"V10",tvalues(it))
    mx = wrf_user_getvar(a,"MAPFAC_M",10)

    opts = res
    opts = set_vc_res(opts)
    opts@vcMinDistanceF = 0.005

    opts@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots
    opts@FieldTitle = "Wind"       ; overwrite Field Title

    dim=dimsizes(u10)
    div=new( (/ dim(0), dim(1) /) , typeof(u10))
    div = wrf_div(u10,v10,dx,dy,mx)

    opts_c = res
    opts_c  = set_cn_resorces(opts_c)
    opts_c  = set_high_res_coast(opts_c)
    opts_c = set_map_latlon_res(opts_c,139.,145.5,43.,48.)

    ; print(max(div) + " " + min(div))
    ; set_cn_limits(opts_c,-.02,.001,.0005)

    opts_c@lbLabelBarOn = False
    opts_c@cnLinesOn = False
    opts_c@sfXArray = xlon
    opts_c@sfYArray = xlat

    delete_attrs(opts_c)
    delete_attrs(opts)

    print("plotting cn")
    cn = gsn_csm_contour_map(wks,div,opts_c)
    print("plotting vector")
    vector = gsn_csm_vector(wks,u10(:,:),v10(:,:),opts)
    overlay(cn,vector)
    plot(it) = cn

  end do
  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 3                ; skip every other label
  pres@lbOrientation   = "Horizontal"     ; vertical label bar
  pres = set_panel_resources(pres)
  panelize_2col(wks,plot,pres)

end
