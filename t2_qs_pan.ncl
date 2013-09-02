load "$nsc/yagUtils.ncl"
import("shea_util")

begin
  a = set_inputfile()

  tvalues = (/71, 82, 95, 119 /)
  type = "pdf"

  out = "t2_qs_pan"
  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"StepSeq25")
  gsn_reverse_colormap(wks)

  varname = "QSNOW"
  noflevels = 32                ; how many layers should be added

  times  = wrf_user_list_times(a)  ; get times in the file
  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  res = True
  res = set_res_no_frame(res)
  res = set_lb_res(res)
  res = set_tm_size_res(res)
  res = set_high_res_coast(res)
  res = set_aspectratio(xlat,res)
  res@mpGeophysicalLineThicknessF = 3
  res@gsnMajorLatSpacing = 1
  res@gsnMajorLonSpacing = 1


  res@cnFillOn = True
  res@cnLinesOn = False
  res@lbLabelBarOn = False
  res@gsnLeftString = ""
  res@gsnRightString = ""
  res = set_map_latlon_res(res,142.,145,43.5,47.)
  set_res_cn_limits(res,-12.,0.,.5)
;  set_res_cn_limits(res,260.,280.,.5)

  opts = True
  opts@cnLinesOn = True
  opts@cnLevelFlags = False
  opts@cnInfoLabelOn = False
  set_res_cn_limits(opts, 0., 0.026, .002 )

  angle = 0.
  lev = 970

  do it = 0, noft - 1, 1

    vt = tvalues(it)
    print("working with: " + times(vt))

;    t2 = wrf_user_getvar(a,"T2",vt)
; use of different level
    p  = wrf_user_getvar(a,"pressure",vt)
    T =  wrf_user_getvar(a,"tc",vt)
    t2 = wrf_user_intrp3d(T,p,"h",lev,angle,False)
    t2@lat2d = xlat
    t2@lon2d = xlon

    wgted_var = wrf_user_getvar_weighted_sum(a,varname,vt)
    wgted_var = wgted_var * 1000. ;
    wgted_var@units = "g"
    wgted_var@lat2d = xlat
    wgted_var@lon2d = xlon
    plot(it) = gsn_csm_contour_map_overlay(wks,t2,wgted_var,res,opts)

    if ( it .eq. 2 ) then
      planes = (/(/217,378,98,372/),(/252,350,80,301/), (/300,378,56,176/) , \
                 (/303,382,62,237/)/)
      plane = new(4,float)
      plane = planes(3,:)

      opts = True
      lat_plane = wrf_user_intrp2d(xlat,plane,angle,opts)
      lon_plane = wrf_user_intrp2d(xlon,plane,angle,opts)

      lnres = True
      lnres@gsLineThicknessF = 5.0
      lnres@gsLineColor = "Red"
      lnres@sfXArray = xlon
      lnres@sfYArray = xlat

      dum = new(dim_len0(lon_plane),graphic)

;      do ii = 0,dim_len0(lon_plane)-2
      do ii = 0, 160
        dum(ii) = gsn_add_polyline(wks,plot(it),(/lon_plane(ii),lon_plane(ii+1)/), \
                                   (/lat_plane(ii),lat_plane(ii+1)/),lnres)
      end do
    end if
  end do

  pres = set_panel_resources(True)
  pres@lbLabelStride = 6
  panelize_2col(wks,plot,pres)

end
;;; t2_qs_pan.ncl ends here
