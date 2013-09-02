load "$nsc/yagUtils.ncl"
begin
  a = wrf_input_file("wrfout")

  wks = gsn_open_wks("png","domain")
  mp_res = wrf_map_resources(a,True)
  mp_res = set_res_highres_coast(mp_res)
  mp  = wrf_map(wks,a,mp_res)

  hgt = hgt_contour(a,wks,True)

  overlay(mp,hgt)

  draw(wks)
  frame(wks)

end
