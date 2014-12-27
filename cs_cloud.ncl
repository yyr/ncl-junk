import("yag_utils")

begin
  a = set_inputfile()
  type = "png"

  time = 64
  wks = gsn_open_wks(type,"cs_cloud")

  plane = new(4,float)
  plane = (/263,104,305,158/)

  angle = 0.                    ; intialize
  angle = angle_with_horizontal(plane(0),plane(1),plane(2),plane(3))

  res = True
  res = set_res_no_frame(res)
  set_res_aspectratio_manual(res,0.8,0.3)

  FirstTime = True              ; for calculating top level
  times = a->Times

  do it = time,time
    print("Working on time: " + chartostring(times(it,5:15)))

    qs = wrf_my_getvar(a,"QCLOUD",it)

    p  = wrf_my_getvar(a, "pressure",it)
    qs_plane = wrf_user_intrp3d(qs,p,"v",plane,angle,True)

    if ( FirstTime ) then
      zmax = 550.
      zz = wrf_user_intrp3d(p,p,"v",plane,angle,True)

      zmin = 1000
      nice_levs = floor((zmin-zmax)/50)*50
      zmax = zmin - nice_levs
      dims = dimsizes(zz)
      zmax_pos = dims(0)-1

      do imax = 1,dims(0)-1
        if ( .not.ismissing(zz(imax,0)) .and. zz(imax,0) .ge. zmax ) then
          zmax_pos = imax
        end if
      end do
      zspan = zmax_pos
      zmax = zz(zmax_pos,0)
      nz = floattoint((zmin-zmax)/50+1)
      FirstTime = False
    end if

    opts_xy                         = res
    opts_xy@tiYAxisString           = "Pressure (mb)"
    opts_xy@trYLog                  = False  ; use a logarithmic coordinate system for the Y-axis
    opts_xy@cnMissingValPerimOn     = True
    opts_xy@cnMissingValFillColor   = 0
    opts_xy@cnMissingValFillPattern = 11
    opts_xy@tmYLMode                = "Explicit"
    opts_xy@tmYLValues              = fspan(0,zspan,nz)           ; Create tick marks
    opts_xy@tmYLLabels              = sprintf("%.0f",fspan(zmin,zmax,nz))
    opts_xy@tiXAxisFontHeightF      = 0.02
    opts_xy@tiYAxisFontHeightF      = 0.02
    opts_xy@tfDoNDCOverlay = True

    opts_pv = opts_xy
    opts_pv@pmLabelBarOrthogonalPosF = -0.07
    opts_pv@cnFillOn = True
    opts_pv@gsnSpreadColors = True
    opts_pv@cnLevelFlags = "LineOnly"
    opts_pv@cnLevelFlag = False
    opts_pv@cnLineLabelsOn = False

    set_res_cn_limits(opts_pv, 0.0001,0.001,.0001)
    opts_pv@lbLabelStride = 4
    opts_pv = set_res_lb(opts_pv)

    date_string = chartostring(times(it,5:15))
    opts_pv@gsnCenterString = date_string

    contour_qs = gsn_csm_contour(wks,qs_plane(0:zmax_pos,:),opts_pv)
    draw(contour_qs)
    frame(wks)
  end do
end
