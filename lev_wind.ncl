;; doc:
;;  (wrf) generate a horizontal plot at a given pressure level.

load "$nsc/yagUtils.ncl"

begin
  a = set_inputfile()

  type = "png"
  at_p = 500.
  out  = "wind10" + at_p

  wks = gsn_open_wks(type,out)

  res = True
  res@tfDoNDCOverlay = True
  res@gsnSpreadColors = True    ;spread Colors
  res = set_vc_res(res)
  res = set_no_frame_res(res)
  res = set_high_res_coast(res)
  opts = set_vc_resources(res)

  times  = wrf_user_list_times(a)

  do it = 0, dim_len0(times), 1   ; LOOP NAME
    print(it + ": Working on time: " + times(it))

    res = wrf_map_resources(a,res)
    delete_attrs(res)
    u = wrf_user_getvar(a,"ua",it)   ; U component of the wind at 10m
    v = wrf_user_getvar(a,"va",it)   ; V component of the wind at 10m

    p  = wrf_user_getvar(a,"pressure",it) ; total pressure

    u_plevel = wrf_user_intrp3d(u,p,"h",at_p,0.,False)
    v_plevel = wrf_user_intrp3d(v,p,"h",at_p,0.,False)

    ; vector = gsn_vector_map(wks,u_plevel(:,:),v_plevel(:,:),res)
    vector = gsn_vector_map(wks,u(0,:,:),v(0,:,:),res)

    delete(vector)

    draw(wks)
    frame(wks)
  end do
end
