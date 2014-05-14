load "$nsc/yagUtils.ncl"
import("shea_util")

begin
  type = "pdf"
  varname = "T2"

  out = "h" + varname
  wks = gsn_open_wks(type,out)

  a = set_inputfile()
  times = a->Times
  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  res = True
  res = set_res_cn(res)
;  set_res_cn_limits(res, 1, 20, 1)

  res@gsnLeftString   = "Coloumn integrated cloud, graup and ice,"
  res@lbLabelStride   = 3
  res@tfDoNDCOverlay = True
  res@lbTitleOn = False
  res = set_res_no_frame(res)
  res = set_res_highres_coast(res)

  ; do it = 0, dim_len0(times) - 1 , 1
  do it = 32, 41 , 1
    vt = it
    system("echo " + vt + ": " + "working with: " + chartostring(times(vt,5:15)))

    var = wrf_user_getvar(a,varname,vt)
    res = wrf_map_resources(a,res)
    res = set_lb_resources(var,res)
    date_string = chartostring(times(vt,5:15))
    res@gsnCenterString = date_string


    delete_attrs(res)
    plot = gsn_csm_contour_map(wks,var,res)
    draw(wks)
    frame(wks)
  end do

end
