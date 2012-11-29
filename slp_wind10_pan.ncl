;    File: wind10.ncl
; Created: Friday, September 22 2011
; License: GPL v3 or later.

load "$nsc/yagUtils.ncl"

begin

  a = set_inputfile()
  tvalues = (/ 48,72,90/)   ;specify desired timestep outputs must be even

  type = "png"
  out  = "slp_wind10_pan"       ;out put file name
  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"OceanLakeLandSnow")
  gsn_reverse_colormap(wks)

  res = True
  res = set_no_frame_res(res)
  res = set_wrf_no_headers(res)
  pltres = set_tm_size_res(res)
  pltres@LatLonOverlay = True ; Don't do an NDC overlay

  mpres  = set_high_res_coast(res)
  mpres = set_tm_size_res(mpres)

  times  = wrf_user_list_times(a)  ; get times in the file
  times_in_file = a->Times
  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  do it = 0, dim_len0(tvalues) -1 ,1

    print("tvalue: " + tvalues(it))
    print("Working on time: " + times(tvalues(it)))
    res@TimeLabel = times(tvalues(it))

    u10 = wrf_user_getvar(a,"U10",tvalues(it))
    v10 = wrf_user_getvar(a,"V10",tvalues(it))
    slp = wrf_user_getvar(a,"slp",tvalues(it))

    cres = res
    cres = set_cn_resorces(cres)
    cres@cnLevelFlags = True
    cres@cnInfoLabelOn = False
    cres@lbLabelBarOn = False
    cres@ContourParameters = (/ 990., 1000., .2 /)

    contour = wrf_contour(a,wks,slp,cres)

    opts = res
    opts = set_vc_res(opts)

    vector = wrf_vector(a,wks,u10(:,:),v10(:,:),opts)
    plot(it) = wrf_map_overlays(a,wks,(/vector,contour/),pltres,mpres)

    out = chartostring(times_in_file(it,5:15))

    txt = create "map_titles" textItemClass wks
      "txString"      : out
      "txFontHeightF" : 0.02
      ;"txFontColor"   : font_color
    end create
    anno = NhlAddAnnotation(plot(it),txt)
    setvalues anno
      "amZone"           : 3
      "amJust"           : "BottomLeft"
      "amSide"           : "Top"
      "amParallelPosF"   : 0.005
      "amOrthogonalPosF" : 0.03
      "amResizeNotify"   : False
    end setvalues


    delete(cres)
    delete(vector)

  end do

  pres                = True    ; mod panel plot
  pres@lbLabelStride  = 4       ; skip every other label
  pres@gsnMaximize = True
  pres@gsnMaximize = True
  pres@lbOrientation = "vertical"
  pres@gsnPanelFigureStrings = (/"a", "b", "c" ,"d"/)
  pres@gsnPanelLabelBar = True                   ; add common colorbar

  gsn_panel(wks,plot,(/1,noft/),pres)

end
