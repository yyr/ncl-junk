; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: t2_qs_pan.ncl
; Created: Monday, November 14 2011
;

load "$nsc/yagUtils.ncl"

begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  tvalues = (/71, 82, 95, 119 /)
  type = "png"
  out = "t2_qs_pan"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"temp_19lev")

  varname = "QSNOW"
  noflevels = 32                ; how many layers should be added

  times  = wrf_user_list_times(a)  ; get times in the file
  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  res = True
  res = set_no_frame_res(res)
  res = set_wrf_no_headers(res)
  pltres = set_tm_size_res(res)
  mpres  = set_high_res_coast(res)
  mpres = set_tm_size_res(mpres)

  do it = 0, noft - 1, 1

    vt = tvalues(it)
    res@TimeLabel = times(vt)   ; Set Valid time to use on plots
    print("working with: " + times(vt))

    wgted_var = wrf_user_getvar_weighted_sum(a,varname,vt)
    wgted_var = wgted_var * 1000. ;
    wgted_var@units = "g"

    opts = res
    opts@ContourParameters = (/ 0., 2.6, .4 /)
    opts@cnLinesOn = True
    opts@cnInfoLabelOn = False
    contour = wrf_contour(a,wks,wgted_var,opts)

    optsT = set_cn_resorces(res)
    optsT@ContourParameters = (/ 260.,280., 0.5 /)

    optsT@cnFillOn         = True
    optsT@cnLinesOn = False
    optsT@lbLabelBarOn = False
    optsT@cnInfoLabelOn = False

    t2 = wrf_user_getvar(a,"T2",vt)
    contour_t = wrf_contour(a,wks,t2,optsT)

    plot(it) = wrf_map_overlays(a,wks,(/contour_t,contour/),pltres,mpres)

    if ( it .eq. 2 ) then
      xlat = a->XLAT(0,:,:)
      xlon = a->XLONG(0,:,:)

      plane = (/303,382,62,237/)
      angle = angle_with_horizontal(plane(0),plane(1),plane(2),plane(3))
      print(angle)

      opts = True
      lat_plane = wrf_user_intrp2d(xlat,plane,angle,opts)
      lon_plane = wrf_user_intrp2d(xlon,plane,angle,opts)

      lnres = True
      lnres@gsLineThicknessF = 3.0
      lnres@gsLineColor = "Red"

      print(lat_plane)

      dum = new(dim_len0(lon_plane),graphic)

      do ii = 0,dim_len0(lon_plane)-2
        dum(ii) = gsn_add_polyline(wks,plot(it),(/lon_plane(ii),lon_plane(ii+1)/), \
                (/lat_plane(ii),lat_plane(ii+1)/),lnres)
      end do

    end if


  end do

; Panelize
  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 4                ; skip every other label
  pres@gsnPanelBottom = 0.1              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@lbOrientation = "vertical"
  pres@gsnMaximize = True
  pres@gsnPanelFigureStrings = (/"a", "b", "c" ,"d"/)
  pres@amJust   = "TopLeft"

  gsn_panel(wks,plot,(/2, noft/2 /),pres)        ; create panel plot

end
;;; t2_qs_pan.ncl ends here
