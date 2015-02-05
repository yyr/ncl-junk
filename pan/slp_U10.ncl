;    File: slp_wind10_pan.ncl
; Created: Friday, September 22 2011
; License: GPL v3 or later.

import("yag_utils")
begin
  a = set_inputfile()
  tvalues = (/ 62,70,85,95,110,120 /)

  out = "slp_U10"       ;out put file name
  type = "pdf"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

  times = a->Times
  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  res = True
  res = set_res_no_frame(res)
  res = set_res_highres_coast(res)
  res@tfDoNDCOverlay = True
  res@lbTitleOn = False

  opts = res
  thin = 10

  res = set_res_cn_lines(res)
  set_res_cn_limits(res, 970, 1030,1)

  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 0, noft - 1, 1   ; LOOP NAME
    vt = tvalues(it)
    print("tvalue: " + tvalues(it))
    slp = wrf_user_getvar(a,"slp",tvalues(it))
    u = wrf_user_getvar(a,"U10",tvalues(it))
    v = wrf_user_getvar(a,"V10",tvalues(it))

    res = wrf_map_resources(a,res)
    res = set_lb_resources(slp,res)
    date_string = chartostring(times(vt,5:15))

    res@gsnCenterString = date_string
    delete_attrs(res)

    opts = res
    opts = set_res_vc(opts)
    vec = gsn_csm_vector(wks,u(::thin,::thin),v(::thin,::thin),res)
    plot(it) = gsn_csm_contour_map(wks,slp,res)
    overlay(plot(it),vec)

  end do

  pres                = True
  pres@lbLabelStride  = 12
  pres@txString         = "sea level pressure"
  panelize_2col(wks,plot,pres)
end
