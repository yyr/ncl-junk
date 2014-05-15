;; doc:
;;  (wrf) generate a horizontal plot at a given pressure level.

load "$nsc/yagUtils.ncl"

begin
  a = set_inputfile()

  type = "pdf"
  at_p = 6
  out  = "pressure_at_level_sigma_" + at_p

  wks = gsn_open_wks(type,out)

  res = True
  res@tfDoNDCOverlay = True
  res = set_res_cn(res)
  res = set_res_no_frame(res)
  res = set_res_highres_coast(res)
  res@cnFillOn = False
  res@cnLineLabelsOn = True
  set_res_cn_limits(res,860,920,5)

  times  = wrf_user_list_times(a)

;  do it = 0, dim_len0(times), 1   ; LOOP NAME

  it = 40

  print(it + ": Working on time: " + times(it))

  res = wrf_map_resources(a,res)
  delete_attrs(res)

  p  = wrf_user_getvar(a,"pressure",it) ; total pressure

  cn = gsn_csm_contour_map(wks,p(at_p,:,:),res)
  draw(wks)
  frame(wks)
;  end do
end
