load "$nsc/yagUtils.ncl"

begin
  a = set_inputfile()
  lev1 = 850
  lev2 = 950

  t1 = 95
  t2 = 94

  out  = "dudt_diff_p" + lev1 + "--" + lev2       ;out put file name
  out1  = "dudt_diff_x_component_p" + lev1 + "--" + lev2       ;out put file name
  out2  = "dudt_diff_y_component_p" + lev1 + "--" + lev2       ;out put file name
  type = "pdf"

  wks = gsn_open_wks(type,out)
  gsn_reverse_colormap(wks)
  wks1 = gsn_open_wks(type,out1)

  wks2 = gsn_open_wks(type,out2)
  gsn_reverse_colormap(wks)


  p  = wrf_user_getvar(a,"pressure",t1)
  u_1 = wrf_user_getvar(a,"ua",t1)
  v_1 = wrf_user_getvar(a,"va",t1)

  u1 = wrf_user_intrp3d(u_1,p,"h",lev1,0.,False)
  v1 = wrf_user_intrp3d(v_1,p,"h",lev1,0.,False)

  p  = wrf_user_getvar(a,"pressure",t2)
  u_2 = wrf_user_getvar(a,"ua",t2)
  v_2 = wrf_user_getvar(a,"va",t2)

  u2 = wrf_user_intrp3d(u_2,p,"h",lev1,0.,False)
  v2 = wrf_user_intrp3d(v_2,p,"h",lev1,0.,False)

  u_lev1 = u1 - u2
  v_lev1 = v1 - v2

  p  = wrf_user_getvar(a,"pressure",t1)
  u_1 = wrf_user_getvar(a,"ua",t1)
  v_1 = wrf_user_getvar(a,"va",t1)

  u1 = wrf_user_intrp3d(u_1,p,"h",lev2,0.,False)
  v1 = wrf_user_intrp3d(v_1,p,"h",lev2,0.,False)

  p  = wrf_user_getvar(a,"pressure",t2)
  u_2 = wrf_user_getvar(a,"ua",t2)
  v_2 = wrf_user_getvar(a,"va",t2)

  u2 = wrf_user_intrp3d(u_2,p,"h",lev2,0.,False)
  v2 = wrf_user_intrp3d(v_2,p,"h",lev2,0.,False)

  u_lev2 = u1 - u2
  v_lev2 = v1 - v2

  u = u_lev1 - u_lev2
  v = v_lev1 - v_lev2

  res = True
  res =  set_vc_res(res)
  plot = wrf_vector(a,wks,u,v,res)
  opts  = set_high_res_coast(True)
  map = wrf_map_overlays(a,wks,plot,opts,opts)

  delete(res)
  res = True
  set_cn_limits(res,-5,30,1)
  res =  set_cn_resorces(res)
  plot = wrf_contour(a,wks1,u,res)
  map = wrf_map_overlays(a,wks1,plot,True,opts)

  delete(res)
  res = True
  set_cn_limits(res,-30.,5.,1)
  res =  set_cn_resorces(res)
  plot = wrf_contour(a,wks2,v,res)
  map = wrf_map_overlays(a,wks2,plot,True,opts)
end
