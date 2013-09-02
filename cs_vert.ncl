; currently plots snow mixing ratio in a given verticle cross section.
; intention to make any give variable in any given line, hard coded right now

load "$nsc/yagUtils.ncl"

begin
  a = set_inputfile()
  type = "pdf"

  wks = gsn_open_wks(type,"cs")
  gsn_define_colormap(wks,"WhiteYellowOrangeRed")    ; Adds the color table

  planes = (/(/217,378,98,372/),(/252,350,80,301/), (/300,378,56,176/) , \
             (/303,382,62,237/), (/191,215,122,168/)/)

  plane = new(4,float)
  plane = planes(3,:)

  angle = 0.                    ; intialize
  angle = angle_with_horizontal(plane(0),plane(1),plane(2),plane(3))

  res = True
  res = set_res_no_frame(res)
  res@gsnLeftString=""
  res@gsnRightString=""
  set_aspectratio_manual(res,0.8,0.3)

  FirstTime = True              ; for calculating top level
  times  = wrf_user_list_times(a)          ; Get times in the file

  do it = 95,95
    print("Working on time: " + times(it) )

    th  = wrf_user_getvar(a,"th",it)
    T = wrf_user_getvar(a,"tc",it)
    qs = wrf_my_getvar(a,"QSNOW",it)
    u  = wrf_my_getvar(a,"ua",it)
    v  = wrf_my_getvar(a,"va",it)
    p  = wrf_my_getvar(a, "pressure",it)
    w  = wrf_my_getvar(a,"wa",it)

    th_plane = wrf_user_intrp3d(th,p,"v",plane,angle,True)
    qs_plane = wrf_user_intrp3d(qs,p,"v",plane,angle,True)
    u_plane  = wrf_user_intrp3d(u,p,"v",plane,angle,True)
    v_plane  = wrf_user_intrp3d(v,p,"v",plane,angle,True)
    w_plane  = wrf_user_intrp3d(w,p,"v",plane,angle,True)

    ; project on to the cross section line (to make a plot vertical plane)
    ; uproj will horizontal component and w will be vertical component
    uproj = u_plane*cos(angle) + v_plane*sin(angle)

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
    opts_xy@trYLog                  = True  ; use a logarithmic coordinate system for the Y-axis
    opts_xy@cnMissingValPerimOn     = True
    opts_xy@cnMissingValFillColor   = 0
    opts_xy@cnMissingValFillPattern = 11
    opts_xy@tmYLMode                = "Explicit"
    opts_xy@tmYLValues              = fspan(0,zspan,nz)           ; Create tick marks
    opts_xy@tmYLLabels              = sprintf("%.0f",fspan(zmin,zmax,nz))
    opts_xy@tiXAxisFontHeightF      = 0.02
    opts_xy@tiYAxisFontHeightF      = 0.02
    opts_xy@tfDoNDCOverlay = True

; Plotting options for PV
    opts_pv = opts_xy
    opts_pv@pmLabelBarOrthogonalPosF = -0.07
    opts_pv@cnFillOn = True
    opts_pv@gsnSpreadColors = True
    opts_pv@cnLevelSelectionMode = "ManualLevels"
    opts_pv@cnLevelFlags = "LineOnly"
    opts_pv@cnLevelFlag = False
    opts_pv@cnLineLabelsOn = False
    opts_pv@cnMinLevelValF       = 0.
    opts_pv@cnMaxLevelValF       = 0.001
    opts_pv@cnLevelSpacingF      = .0001
    opts_pv@lbOrientation = "vertical"
    opts_pv@lbLabelStride = 4
    opts_pv = set_lb_res(opts_pv)

    opts_th = opts_xy
    opts_th@cnSmoothingOn = True
;    opts_th@cnLineColor = "Blue"
    opts_th@cnInfoLabelOn = False
    opts_th@gsnContourLineThicknessesScale = 2.0
    opts_th@cnLineLabelBackgroundColor = "white"
    opts_th@cnInfoLabelOn = False
    opts_th@cnLabelDrawOrder  = "PostDraw"
    opts_th@cnInfoLabelOrthogonalPosF = 0.00
    opts_th@cnMinLevelValF       = 268
    opts_th@cnMaxLevelValF       = 285
    opts_th@cnLevelSpacingF      = 1
    ; opts_pv@gsnSpreadColors = True

    opts_v = True
    opts_v = set_res_no_frame(opts_v)
    opts_v = set_vc_res(opts_v)
    opts_v@vcLineArrowColor = "Blue"

    ; contour_th = gsn_csm_contour(wks,th_plane(0:zmax_pos,0:160),opts_th)
    contour_qs = gsn_csm_contour(wks,qs_plane(0:zmax_pos,0:160),opts_pv)
    vector = gsn_vector(wks,uproj(0:zmax_pos,0:160), \
                        w_plane(0:zmax_pos,0:160),opts_v)

;   overlay(contour_qs,contour_th)
   overlay(contour_qs,vector)
   draw(contour_qs)

    ; overlay(contour_th,vector)
    ; draw(contour_th)

    frame(wks)
  end do
end
