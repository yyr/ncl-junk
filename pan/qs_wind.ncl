import("yag_utils")

begin
  a = set_inputfile()

  ; specify desired timestep outputs must be even
  tvalues = (/ 73,83,91,101 /)

  type = "pdf"
  out = "qs_wind"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

  wind_overlay = True
  varname = "QSNOW"
  thin = 16

; uncomment two line to draw at "lev" instead of 10m.
  lev = 960
  ; angle = 0.

  times  = wrf_user_list_times(a)  ; get times in the file
  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

  opts = True
  opts = set_res_cn(opts)
  opts = set_res_mp_latlon(opts,141.,145,43,47.5)
  opts = set_res_no_frame(opts)
  opts = set_res_lb(opts)
  opts = set_res_tm_size(opts)
  opts = set_res_highres_coast(opts)
  opts = set_aspectratio(xlat,opts)
  opts@cnLineLabelsOn = True
  opts@lbLabelBarOn = False
  opts@gsnMajorLatSpacing = 1
  opts@gsnMajorLonSpacing = 1
  set_res_cn_limits(opts, 1,10,1)

  do it = 0, noft - 1, 1
    vt = tvalues(it)
    print("working with: "+ vt + " , "+ times(vt))
    wgted_var = wrf_user_getvar_weighted_sum(a,varname,vt)

    wgted_var@lat2d = xlat
    wgted_var@lon2d = xlon

    opts@gsnLeftString = times(vt)
    plot(it) = gsn_csm_contour_map(wks,wgted_var,opts)

    if ( wind_overlay ) then
      if ( isdefined("lev") ) then
        u_1 = wrf_user_getvar(a,"ua",vt)
        v_1 = wrf_user_getvar(a,"va",vt)
        p  = wrf_user_getvar(a,"pressure",vt)
        u = wrf_user_intrp3d(u_1,p,"h",lev,0.,False)
        v = wrf_user_intrp3d(v_1,p,"h",lev,0.,False)
      else
        u = wrf_user_getvar(a,"U10",tvalues(it))
        v = wrf_user_getvar(a,"V10",tvalues(it))
      end if

      optsv = True
      optsv@vfXArray = xlon(::thin,::thin)
      optsv@vfYArray = xlat(::thin,::thin)
      optsv@gsnLeftString = ""
      optsv@gsnRightString = ""
      optsv = set_res_vc(optsv)
      optsv@vcLineArrowColor = "blue"

      optsv = set_aspectratio(xlat,optsv)
      optsv = set_res_no_frame(optsv)
      vec = gsn_csm_vector(wks,u(::thin,::thin),v(::thin,::thin),optsv)
      overlay(plot(it),vec)
    end if
  end do

  pres = set_res_panel(True)
  pres@lbLabelStride = 3
  panelize_2col(wks,plot,pres)
end
;;; t2_qs_pan.ncl ends here
