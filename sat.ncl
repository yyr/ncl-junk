load "$nsc/yagUtils.ncl"
import("shea_util")

begin
  type = "pdf"

  out = "sap"
  wks = gsn_open_wks(type,out)

  a = set_inputfile()
  times = a->Times

  res = True
  res = set_res_cn(res)
  set_res_cn_limits(res, 260, 285, 1) ;  (/ 265.,275., 0.5 /)

  res@gsnLeftString   = "SAP"
  res@lbLabelStride   = 3
  res@tfDoNDCOverlay = True
  res@lbTitleOn = False
  res = set_res_no_frame(res)
  res = set_res_highres_coast(res)

;  do it = 0, dim_len0(times) - 1 , 1
  do it = 58, dim_len0(times) - 1 , 1 ;76 , 1
;  do it = 66, 86 , 4
    vt = it
    system("echo " + vt + ": " + "working with: " + chartostring(times(vt,5:15)))
    tk = wrf_user_getvar(a,"tk",vt)

    res = wrf_map_resources(a,res)
    res = set_lb_resources(tk(0,:,:),res)

    date_string = chartostring(times(vt,5:15))
    res@gsnCenterString = date_string

    delete_attrs(res)
    plot = gsn_csm_contour_map(wks,tk(0,:,:),res)
    ; printVarInfo(wgted_var, "wgted_var")
    draw(wks)
    frame(wks)
  end do
end
