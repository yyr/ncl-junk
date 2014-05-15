load "$nsc/yagUtils.ncl"
begin
  a = set_inputfile()

  tvalues = (/ 48,55,62,70,85,95 /)   ;specify desired timestep outputs must be even

  out = "slp_pan"       ;out put file name
  type = "ps"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"helix1")   ; overwrite the .hluresfile color map
  gsn_reverse_colormap(wks)

  res = True
  res@lbLabelBarOn        = False           ; turn off individual cb's

  pltres = True ; Plot resources
  mpres = set_res_highres_coast(True)

  times  = wrf_user_list_times(a)  ; get times in the file

  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 0, noft - 1, 1   ; LOOP NAME
    print("tvalue: " + tvalues(it))

    print("Working on time: " + times(it) )
    res@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots

    slp = wrf_user_getvar(a,"slp",tvalues(it))

    res@gsnDraw              = False              ; Do not draw plot
    res@gsnFrame             = False              ; Do not advance frame
    res@cnInfoLabelOn = False        ; turn off contour info label

    opts = res
    opts@cnFillOn         = True
    opts@cnFillColor = True
    opts@ContourParameters = (/ 972., 996., 1 /)

    contour = wrf_contour(a,wks,slp,opts)
    plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
    delete(contour)

  end do
  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 12         ; skip every other label
  pres@txString         = "sea level pressure"      ; add common title
  panelize_3col(wks,plot,pres)
end
