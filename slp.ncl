import("yag_utils")

begin
  type = "pdf"
  varname = "slp"

  out = varname + "_all"
;  out = varname
  wks = gsn_open_wks(type,out)

  a = set_inputfile()
  times = a->Times

  res = True
  res = set_res_cn_lines(res)
  set_res_cn_limits(res, 1000, 1030,1)

  res@gsnLeftString   = "SLP"
  res@lbLabelStride   = 3
  res@tfDoNDCOverlay = True
  res@lbTitleOn = False
  res = set_res_highres_coast(res)

;  do it = 0, dim_len0(times) - 1 , 1
  do it = 58, 76 , 1
    vt = it
    system("echo " + vt + ": " + "working with: " + chartostring(times(vt,5:15)))

    var = wrf_user_getvar(a,varname,vt)
    res = wrf_map_resources(a,res)
    res = set_lb_resources(var,res)
    date_string = chartostring(times(vt,5:15))
    res@gsnCenterString = date_string

    delete_attrs(res)
    plot = gsn_csm_contour_map(wks,var,res)
  end do
end
