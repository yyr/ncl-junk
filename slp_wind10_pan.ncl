;    File: wind10.ncl
; Created: Friday, September 22 2011
; License: GPL v3 or later.

load "$nsc/yagUtils.ncl"

begin
  a = set_inputfile()
  tvalues = (/71, 82, 95, 119 /)

  type = "ps"
  out  = "div"       ;out put file name
  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"WhiteBlue")
  gsn_reverse_colormap(wks)

  res = True
  res = set_res_no_frame(res)
  res = set_wrf_no_headers(res)

  pltres = set_tm_size_res(res)
  pltres = set_res_no_frame(pltres)

  mpres  = set_high_res_coast(res)
  mpres = set_tm_size_res(mpres)

  times  = wrf_user_list_times(a)  ; get times in the file
  times_in_file = a->Times
  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  do it = 0, dim_len0(tvalues) -1 ,1
    print("Working on time: " + times(tvalues(it)))

    u10 = wrf_user_getvar(a,"U10",tvalues(it))
    v10 = wrf_user_getvar(a,"V10",tvalues(it))
    slp = wrf_user_getvar(a,"slp",tvalues(it))

    cres = res
    cres = set_res_cn(cres)
    cres@cnFillOn = True
    cres@cnFillColor = False
    cres@cnLevelFlags = True
    cres@lbLabelBarOn = False
    cres@ContourParameters = (/ 970., 1010., 1 /)

    contour = wrf_contour(a,wks,slp,cres)

    opts = res
    opts = set_vc_res(opts)

    vector = wrf_vector(a,wks,u10(:,:),v10(:,:),opts)
    plot(it) = wrf_map_overlays(a,wks,(/vector,contour/),pltres,mpres)

  end do

  pres                = True    ; mod panel plot
  pres@lbLabelStride  = 4       ; skip every other label
  pres@lbOrientation = "vertical"
  pres@gsnPanelFigureStrings = (/"a", "b", "c" ,"d"/)
  panelize_2col(wks,plot,pres)
end
