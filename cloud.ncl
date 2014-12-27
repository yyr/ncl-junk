; Created: 2013-04-23 15:55
import("yag_utils")

begin
  type = "pdf"
  varname = (/"QCLOUD", "QSNOW", "QGRAUP", "QICE", "QRAIN"/)

;  out = "cloud"
  out = "cloud"
  wks = gsn_open_wks(type,out)

  a = set_inputfile()
  times = a->Times

  res = True
  res = set_res_cn(res)
  set_res_cn_limits(res, 0, 5, .5)

  res@gsnLeftString   = "CI cloud"
  res@lbLabelStride   = 3
  res@tfDoNDCOverlay = True
  res@lbTitleOn = False
  res = set_res_highres_coast(res)

  do it = 0, dim_len0(times) - 1 , 2
;  do it = 58, 76 , 1
    vt = it
    system("echo " + vt + ": " + "working with: " + chartostring(times(vt,5:15)))
    wgted_var = wrf_user_getvar_weighted_sum(a,varname,vt)

    res = wrf_map_resources(a,res)
    res = set_lb_resources(wgted_var(:,:),res)

    date_string = chartostring(times(vt,5:15))
    res@gsnCenterString = date_string

    delete_attrs(res)
    plot = gsn_csm_contour_map(wks,wgted_var,res)
  end do
end
;;; wgt_cloud.ncl
