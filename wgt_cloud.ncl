; Created: 2013-04-23 15:55

load "$nsc/yagUtils.ncl"
import("shea_util")

begin
  type = "ps"
  ; type = "X11"
  varname = "QSNOW"

  out = "wgt_cloud"
  wks = gsn_open_wks(type,out)

  a = set_inputfile()
  times = a->Times
  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  res = True
  res = set_cn_resorces(res)
  set_cn_limits(res, 0, 0.002, .0001)
  res@gsnLeftString   = "Integrated Cloud"
  res@lbLabelStride   = 3
  res@tfDoNDCOverlay = True
  res@lbTitleOn = False
  res = set_no_frame_res(res)
  res = set_high_res_coast(res)

  do it = 0, dim_len0(times) - 1 , 1
  ; do it = 20, 22 , 1
    vt = it
    system("echo " + vt + ": " + "working with: " + chartostring(times(vt,5:15)))

    wgted_var = wrf_user_getvar_weighted_sum(a,(/"QSNOW"/),vt)
    ; wgted_var = wrf_user_getvar_weighted_sum(a,(/"QSNOW", "QCLOUD", "QRAIN", "QICE"/),vt)
    wgted_var = wgted_var * 1000. ;
    wgted_var@units = "g"
    ; print("Minimum: "+min(wgted_var)+"   Maximum: "+max(wgted_var) )

    res = wrf_map_resources(a,res)
    res = set_lb_resources(wgted_var(:,:),res)

    date_string = chartostring(times(vt,5:15))
    res@gsnCenterString = date_string

    delete_attrs(res)
    plot = gsn_csm_contour_map(wks,wgted_var,res)
    draw(wks)
    frame(wks)
  end do

end
;;; wgt_cloud.ncl