load "$nsc/yagUtils.ncl"
import("shea_util")

begin
  a = set_inputfile()

  tvalues = (/71, 82, 95, 119 /)
  type = "pdf"

  out = "t2_qs_pan"
  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"BlGrYeOrReVi200")
;  gsn_reverse_colormap(wks)

  wind_overlay = True
  varname = "QSNOW"
  thin = 16

  times  = wrf_user_list_times(a)  ; get times in the file
  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  res = True
  res = set_res_no_frame(res)
  res = set_res_lb(res)
  res = set_res_tm_size(res)
  res = set_res_highres_coast(res)
  res = set_aspectratio(xlat,res)
  res@mpGeophysicalLineThicknessF = 3
  res@gsnMajorLatSpacing = 1
  res@gsnMajorLonSpacing = 1

  res@cnFillOn = True
;  res@cnLinesOn = False
  res@lbLabelBarOn = False
  res@gsnLeftString = ""
  res@gsnRightString = ""
  res = set_res_mp_latlon(res,141.,145,43,47.5)
  set_res_cn_limits(res,-14.,0.,.5)
;  set_res_cn_limits(res,250.,280.,1)

  cn_levs = (/2., 5., 9., 12./)
  opts = True
  opts@cnFillOn = False
  opts@cnLinesOn = True
  opts@cnLineLabelsOn = True
  opts@cnLevelFlags = cn_levs
  opts@cnLineLabelPlacementMode = "constant"
  opts@cnLineLabelInterval = 1
  opts@cnInfoLabelOn = False
  set_res_cn_limits_explicit(opts, cn_levs)

  angle = 0.
  lev = 960
  lev_t = 940

  do it = 0, noft - 1, 1

    vt = tvalues(it)
    print("working with: "+ vt + " "+ times(vt))

    p  = wrf_user_getvar(a,"pressure",vt)
    T =  wrf_user_getvar(a,"tc",vt)
    t2 = wrf_user_intrp3d(T,p,"h",lev_t,angle,False)
;    t2 = wrf_user_getvar(a,"TSK",vt)
;    t2 = wrf_user_getvar(a,"T2",vt)

    t2@lat2d = xlat
    t2@lon2d = xlon

    wgted_var = wrf_user_getvar_weighted_sum(a,varname,vt)
    ; wgted_var1 = wrf_user_getvar_weighted_sum(a,"QCLOUD",vt)
    ; wgted_var2 = wrf_user_getvar_weighted_sum(a,"QICE",vt)
    ; wgted_var3 = wrf_user_getvar_weighted_sum(a,"QGRAUP",vt)
    ; wgted_var = wgted_var + wgted_var1 + wgted_var2  + wgted_var3

    wgted_var@lat2d = xlat
    wgted_var@lon2d = xlon

    plot(it) = gsn_csm_contour_map_overlay(wks,t2,wgted_var,res,opts)
    if ( wind_overlay ) then
      u_1 = wrf_user_getvar(a,"ua",vt)
      v_1 = wrf_user_getvar(a,"va",vt)
      p  = wrf_user_getvar(a,"pressure",vt)
      u = wrf_user_intrp3d(u_1,p,"h",lev,0.,False)
      v = wrf_user_intrp3d(v_1,p,"h",lev,0.,False)
      optsv = True
      optsv@vfXArray = xlon(::thin,::thin)
      optsv@vfYArray = xlat(::thin,::thin)
      optsv@gsnLeftString = ""
      optsv@gsnRightString = ""
      optsv = set_res_vc(optsv)
      optsv@vcLineArrowColor = "white"
      optsv = set_aspectratio(xlat,optsv)
      optsv = set_res_no_frame(optsv)
      vec = gsn_csm_vector(wks,u(::thin,::thin),v(::thin,::thin),optsv)
      overlay(plot(it),vec)
    end if

    if ( it .eq. 2 ) then
      planes = (/(/217,378,98,372/),(/252,350,80,301/), (/300,378,56,176/) , \
                 (/303,382,62,237/),(/236,288,130,219/)/)
      plane = new(4,float)
      plane = planes(3,:)

      optsl = True
      lat_plane = wrf_user_intrp2d(xlat,plane,angle,optsl)
      lon_plane = wrf_user_intrp2d(xlon,plane,angle,optsl)

      lnres = True
      lnres@gsLineThicknessF = 5.0
      lnres@gsLineColor = "Red"
      lnres@sfXArray = xlon
      lnres@sfYArray = xlat

      dum = new(dim_len0(lon_plane),graphic)

      do ii = 0,dim_len0(lon_plane)-2
        dum(ii) = gsn_add_polyline(wks,plot(it),(/lon_plane(ii),lon_plane(ii+1)/), \
                                   (/lat_plane(ii),lat_plane(ii+1)/),lnres)
      end do
    end if
  end do

  pres = set_res_panel(True)
  pres@lbLabelStride = 6
  panelize_2col(wks,plot,pres)

end
;;; t2_qs_pan.ncl ends here
