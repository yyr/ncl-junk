;;  Author: Yagnesh Raghava Yakkala <hi@yagnesh.org>
;; Created: Wednesday, September 21 2011

; panel plot for QFX.
; QFX            1  0  UPWARD MOISTURE FLUX AT THE SURFACE (kg m-2 s-1)

import("yag_utils")

begin
  a = set_inputfile()

  type = "pdf"
  out = "hfx_multi_pan"

  vt = 95

  vars = (/ "HFX", "LH",  "ACHFX", "ACGRDFLX" /)

  wks = gsn_open_wks(type,out)

  times = a->Times
  noft = dim_len0(vars)
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

  res@lbLabelBarOn = True
  res@gsnMajorLatSpacing = 1
  res@gsnMajorLonSpacing = 1
  res@gsnLeftString = "QFX"
  set_res_cn_limits(res,0.,.0003,.00002)

  do it = 0, noft - 1, 1
    var = vars(it)
    print("Working on: " + var)

    h = wrf_user_getvar(a,var,vt)
    h@lat2d = xlat
    h@lon2d = xlon

    date_string = chartostring(times(vt,5:15))
    res@gsnCenterString = date_string

    if ( var .eq. "HFX" ) then
      ; var = "HFX"
      gsn_define_colormap(wks,"hotcold_18lev")
      set_res_cn_limits(res,-100,700.,40)
      res@gsnLeftString = "HFX"
    end if

    if ( var .eq. "LH" ) then
      ; var = "LH"
      set_res_cn_limits(res,-100,500.,40)
      res@gsnLeftString = "LH"
    end if

    if ( var .eq. "ARHFX" ) then
      ; var = "ACHFX"
      set_res_cn_limits(res,-10,100.,2)
      res@gsnLeftString = "ACHFX"
    end if

    if ( var .eq. "ACGRDFLX" ) then
      ; var = "ACGRDFLX"
      h = h / 1e6
      h@units = "MJ m-2"
      set_res_cn_limits(res,-5.,10.,.5)
      res@gsnLeftString = "ACGRDFLX"
    end if

    plot(it) = gsn_csm_contour_map(wks,h,res)
  end do

  pres = set_res_panel(True)
  pres@lbLabelStride  = 3
  pres@gsnPanelLabelBar = False
  panelize_2col(wks,plot,pres)
end
