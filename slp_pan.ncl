import("yag_utils")
begin
  a = set_inputfile()
  tvalues = (/19, 22, 25, 28, 32, 35 /)

  out = "slp_pan"       ;out put file name
  type = "pdf"

  wks = gsn_open_wks(type,out)
  times = a->Times
  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  res = True
  res = set_res_cn_lines(res)
  res = set_res_no_frame(res)
  res = set_res_highres_coast(res)
  res@tfDoNDCOverlay = True
  res@lbTitleOn = False
  set_res_cn_limits(res, 1000, 1030,1)

  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 0, noft - 1, 1   ; LOOP NAME
    vt = tvalues(it)
    print("tvalue: " + tvalues(it))
    slp = wrf_user_getvar(a,"slp",tvalues(it))
    res = wrf_map_resources(a,res)

    res = set_lb_resources(slp,res)
    date_string = chartostring(times(vt,5:15))
    res@gsnCenterString = date_string
    delete_attrs(res)

    plot(it) = gsn_csm_contour_map(wks,slp,res)
  end do

  pres                = True
  pres@lbLabelStride  = 12
  pres@txString         = "sea level pressure"
  panelize_2col(wks,plot,pres)
end
