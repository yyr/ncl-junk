;    File: t2_w10_qs.ncl
; Created: Monday, November 14 2011
; License: GPL v3 or later.

load "$nsc/yagUtils.ncl"

begin

  a = set_inputfile()

  type = "png"

  varname = "QSNOW"
  noflevels = 32                ; how many layers should be added

  times  = wrf_user_list_times(a)  ; get times in the file
  xlat = a->XLAT(0,:,:)
  xlon = a->XLONG(0,:,:)

;  do it = 0, dim_len0(times) - 1 , 1
  do it = 110,111,1
    vt = it
    print("working with: " + times(vt))

    out = "qs_over" + it
    wks = gsn_open_wks(type,out)
;    gsn_define_colormap(wks,"WhiteBlue")
;    gsn_reverse_colormap(wks)

    wgted_var = wrf_user_getvar_weighted_sum(a,varname,vt)
    wgted_var = wgted_var * 1000. ;
    wgted_var@units = "g"

    res = True
    res@TimeLabel = times(vt)   ; Set Valid time to use on plots

    opts = res
    opts@ContourParameters = (/ 0., 1.6, .1 /)
    opts@sfXArray = xlon
    opts@sfYArray = xlat
    contour = wrf_contour(a,wks,wgted_var,opts)

    optsT = res
    optsT@sfXArray = xlon
    optsT@sfYArray = xlat
    optsT@cnFillOn  = True
    optsT@cnFillColor = True
    optsT@ContourParameters = (/ 250.,270., 0.5 /)

    t2 = wrf_user_getvar(a,"T2",vt)
    contour_t = wrf_contour(a,wks,t2,optsT)

    ;;-- wind10  --
    u10 = wrf_user_getvar(a,"U10",vt)   ; U component of the wind at 10m
    v10 = wrf_user_getvar(a,"V10",vt)   ; V component of the wind at 10m

    optsW = res
    optsW@FieldTitle = "Wind"       ; overwrite Field Title
    optsW  = set_vc_res(optsW)
    vector = wrf_vector(a,wks,u10,v10,optsW)


    ;;-- plot/overlay all  --
    pltres = True ; Plot resources
    pltres = set_wrf_no_headers(pltres)
    pltres = set_tm_size_res(res)
    pltres@LatLonOverlay = True ; Don't do an NDC overlay

    mpres  = True  ; Map resources
    mpres = set_high_res_coast(mpres)
    mpres = set_map_latlon_res(mpres,139.,145.5,43.,48.)
    mpres = set_wrf_no_headers(mpres)

    mpres = set_tm_size_res(mpres)
    mpres@lbOrientation = "vertical"

    plot = wrf_map_overlays(a,wks,(/contour_t,vector,contour/),pltres,mpres)

    draw(wks)
    frame(wks)

    delete(pltres)
    delete(mpres)
    delete(optsW)
    delete(optsT)
    delete(opts)


  end do

end
;;; t2_w10_qs.ncl ends here
