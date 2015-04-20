;;  Author: Yagnesh Raghava Yakkala <hi@yagnesh.org>
;; Created: Wednesday, September 21 2011

; panel plot for QFX.
; QFX            1  0  UPWARD MOISTURE FLUX AT THE SURFACE (kg m-2 s-1)

import("yag_utils")

begin
  a = set_inputfile()

  type = "pdf"
  out = "qfx_pan"

  tvalues = (/ 60, 70, 82, 95, 102, 114, 126, 143/)

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"hotcold_18lev")

  times = a->Times
  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  res = True
  res = set_res_cn(res)
  res = set_res_no_frame(res)
  res = set_res_lb(res)
  res = set_res_tm_size(res)
  res = set_res_highres_coast(res)
  res = set_res_mp_latlon(res,141.,145,43,47.5)

  res@lbLabelBarOn = False
  res@gsnMajorLatSpacing = 1
  res@gsnMajorLonSpacing = 1
  res@gsnLeftString = "QFX"
  set_res_cn_limits(res,0.,.0003,.00002)

  do it = 0, noft - 1, 1
    vt = tvalues(it)
    print("tvalue: " + tvalues(it))
    date_string = chartostring(times(vt,5:15))
    res@gsnCenterString = date_string


    h = wrf_user_getvar(a,"QFX",vt)
    h@lat2d = xlat
    h@lon2d = xlon
    plot(it) = gsn_csm_contour_map(wks,h,res)
  end do

  pres = set_res_panel(True)
  pres@lbLabelStride  = 3
  panelize_2col(wks,plot,pres)
end
