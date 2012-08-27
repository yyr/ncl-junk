load "$nsc/yagUtils.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  tvalues = (/ 98,99 /)   ;specify desired timestep outputs must be even

  type = "x11"
  at_p = 500.
  out  = "wind10" + at_p

  wks = gsn_open_wks(type,out)

  res = True
  res@Footer = False
  res@gsnSpreadColors = True    ;spread Colors

  mpres  = True  ; Map resources
  pltres = True ; Plot resources
  mpres = set_high_res_coast(mpres)

  times  = wrf_user_list_times(a)
  ntimes = dimsizes(times)

  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

 do it = 0, noft - 1, 1   ; LOOP NAME
    print("tvalue: " + tvalues(it))

    print("Working on time: " + times(tvalues(it)))
    res@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots


    u = wrf_user_getvar(a,"ua",tvalues(it))   ; U component of the wind at 10m
    v = wrf_user_getvar(a,"va",tvalues(it))   ; V component of the wind at 10m

    p  = wrf_user_getvar(a,"pressure",tvalues(it)) ; total pressure
    printVarSummary(p)
    printVarSummary(u)
    printVarSummary(at_p)

    u_plevel = wrf_user_intrp3d(u,p,"h",at_p,0.,False)
    v_plevel = wrf_user_intrp3d(v,p,"h",at_p,0.,False)

    opts = res
    opts@FieldTitle = "Wind"       ; overwrite Field Title
                                ; opts@NumVectors = 40           ; density of wind barbs
    opts@InitTime = False
    opts@vcGlyphStyle = "LineArrow"
    opts@vcMonoLineArrowColor = True
    opts@vcGlyphStyle        = "CurlyVector"    ; turn on curly vectors
    pltres@NoTitles = True


    vector = wrf_vector(a,wks,u_plevel(:,:),v_plevel(:,:),opts)
    plot(it) = wrf_map_overlays(a,wks,(/vector/),pltres,mpres)
    delete(vector)
  end do

end