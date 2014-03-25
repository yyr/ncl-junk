load "$nsc/yagUtils.ncl"
import("shea_util")

begin
  ; directories=(/"/home/yagnesh/WRFMPI/WRFV3/test/bd/res" \
  ;               , "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_sak/d3" \
  ;               , "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_hok/d3" \
  ;               , "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_hok_sak/d3" \
  ;               , "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_topo/d3" \
  ;               , "/home/yagnesh/wrf/run/notopsak_20081225/d3/" \
  ;               /)
  directories=(/ "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_sak/d3" \
                , "/home/yagnesh/wrf/run/notopsak_20081225/d3/" \
                , "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_hok/d3" \
                , "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_topo/d3" \
                /)

  type = "pdf"
  out = "t2_qs_pan_multi"
  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"BlGrYeOrReVi200")

  thin = 16
  varname = "QSNOW"
  noflevels = 32                ; how many layers should be added
  plot = new(dim_len0(directories),graphic)

  a = set_inputfile()
  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)
  times  = wrf_user_list_times(a)  ; get times in the file

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
  res@cnLinesOn = False
  res@lbLabelBarOn = False
  res@gsnLeftString = ""
  res@gsnRightString = ""
  res = set_res_mp_latlon(res,141.,145,43,47.5)
  set_res_cn_limits(res,-14.,0.,.5)

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
  vt = 95

  do it = 0, dim_len0(directories) - 1, 1
    a = addfile(directories(it)+"/wrfout_d03_2008-12-25_00:00:00.nc","r")
    announce(directories(it))
    print("working with: " + times(vt))

    p  = wrf_user_getvar(a,"pressure",vt)
    T =  wrf_user_getvar(a,"tc",vt)
    t2 = wrf_user_intrp3d(T,p,"h",lev_t,angle,False)
    t2@lat2d = xlat
    t2@lon2d = xlon

    wgted_var = wrf_user_getvar_weighted_sum(a,varname,vt)
    wgted_var@lat2d = xlat
    wgted_var@lon2d = xlon
    plot(it) = gsn_csm_contour_map_overlay(wks,t2,wgted_var,res,opts)

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

  end do

  pres = True
  pres@gsnPanelFigureStrings = (/"a) NSAK", "b) NTOPSAK", "c) NHOK", "d) NTOPHOK"/)
  pres = set_res_panel(pres)
  pres@lbLabelStride = 6
  panelize_2col(wks,plot,pres)
end
;;; t2_qs_pan.ncl ends here
