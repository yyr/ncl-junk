load "$nsc/yagUtils.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

  type = "png"

  wks = gsn_open_wks(type,"cs")
  gsn_define_colormap(wks,"WhiteYellowOrangeRed")    ; Adds the color table

  planes = (/(/217,378,98,372/),(/252,350,80,301/), (/300,378,56,176/) , \
          (/303,382,62,237/)/)
;  planes = (/(/217,378,98,372/),(/252,350,80,301/), (/300,378,56,176/)/)
  plane = new(4,float)
  plane = planes(3,:)

  angle = 0.                    ; intialize
  angle = angle_with_horizontal(plane(0),plane(1),plane(2),plane(3))

  res = True
  opts = True                   ; Specifying start and end points
  pltres = True
  FirstTime = True              ; for calculating top level

  res@MainTitle = "Vertical Plane along the cross section"
  res@Footer = False
  res@vpWidthF = .9
  res@vpHeightF = 1.0

  times  = wrf_user_list_times(a)          ; Get times in the file
  ntimes = dimsizes(times)                 ; Number of times in the file

  nd = rank_of_file_var(a,"P")

;  do it = 70,99                              ; TIME LOOP
  do it = 96,96

    print("Working on time: " + times(it) )
    res@tiMainString =  times(it) + " UTC"        ; Set Valid time to use on plots

    ;th  = wrf_user_getvar(a,"th",it)
    th  = wrf_my_getvar(a,"th_v",it)
;    th_t  = wrf_my_getvar(a,"PH",it)
;    th = th(1:,:,:)
    ; printVarSummary(th)
    qs = wrf_my_getvar(a,"QSNOW",it)
    u  = wrf_my_getvar(a,"ua",it)
    v  = wrf_my_getvar(a,"va",it)
    p  = wrf_my_getvar(a, "pressure",it)
    w  = wrf_my_getvar(a,"wa",it)

    th_plane = wrf_user_intrp3d(th,p,"v",plane,angle,opts)
    qs_plane = wrf_user_intrp3d(qs,p,"v",plane,angle,opts)
    u_plane  = wrf_user_intrp3d(u,p,"v",plane,angle,opts)
    v_plane  = wrf_user_intrp3d(v,p,"v",plane,angle,opts)
    w_plane  = wrf_user_intrp3d(w,p,"v",plane,angle,opts)

    qs_plane@units = "kg"

    ;; perform standard rotation
;    urot_plane  = u_plane*cos(angle) ;- v_plane*sin(angle)
;    vrot_plane  = u_plane*sin(angle) ;+ v_plane*cos(angle)

    uproj = u_plane*cos(angle) + v_plane*sin(angle)

    if ( FirstTime ) then

      zmax = 550.
      zz = wrf_user_intrp3d(p,p,"v",plane,angle,opts)

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
    opts_xy@gsnLeftString           = "Logarithmic Y-axis"
    opts_xy@AspectRatio             = 0.75
    opts_xy@cnMissingValPerimOn     = True
    opts_xy@cnMissingValFillColor   = 0
    opts_xy@cnMissingValFillPattern = 11
    opts_xy@tmYLMode                = "Explicit"
    opts_xy@tmYLValues              = fspan(0,zspan,nz)           ; Create tick marks
    opts_xy@tmYLLabels              = sprintf("%.0f",fspan(zmin,zmax,nz))
    opts_xy@tiXAxisFontHeightF      = 0.020
    opts_xy@tiYAxisFontHeightF      = 0.010
    opts_xy@tmXBMajorLengthF        = 0.02
    opts_xy@tmYLMajorLengthF        = 0.02
    opts_xy@tmYLLabelFontHeightF    = 0.0001
    opts_xy@PlotOrientation         = th_plane@Orientation


; Plotting options for PV
    opts_pv = opts_xy
    opts_pv@pmLabelBarOrthogonalPosF = -0.07
    opts_pv@cnFillOn = True
    opts_pv@gsnSpreadColors = True
    opts_pv@ContourParameters = (/ 0., .002, .0003/)


    opts_th = opts_xy
    opts_th@cnSmoothingOn = True
    opts_th@cnLineColor = "Blue"
    opts_th@gsnContourLineThicknessesScale = 2.0
    opts_th@cnLineLabelBackgroundColor = "white"
    opts_th@cnLineLabelFontHeightF   = 0.018
    opts_th@cnLabelDrawOrder  = "PostDraw"
    opts_th@cnInfoLabelOrthogonalPosF = 0.00
    ;; opts_th@ContourParameters  = (/ 270., 460., 2. /)

; Vertical Velocity
    ;; w_plane = 10.*w_plane
    opts_w   = res
    opts_w@UnitLabel             = "m/3"

;    opts_w@cnFillOn = True
    opts_w@cnFillColor = True
    opts_w@gsnSpreadColorEnd     = -3
    contour_w = wrf_contour(a,wks, w_plane,opts_w)

    opts_v = res
    opts_v = set_no_frame_res(opts_v)
    opts_v = set_vc_res(opts_v)
    opts_v@vcRefMagnitudeF = 10.

    contour_th = wrf_contour(a,wks,th_plane(0:zmax_pos,:),opts_th)
    contour_qs = wrf_contour(a,wks,qs_plane(0:zmax_pos,:),opts_pv)
    vector = gsn_vector(wks,uproj(0:zmax_pos,:),w_plane(0:zmax_pos,:),opts_v)

    plot = wrf_overlays(a,wks,(/contour_th,contour_qs,vector/),pltres)

    delete(opts_th)
    delete(opts_pv)
    delete(opts_v)
    delete(th_plane)
    delete(qs_plane)
    delete(u_plane)
    delete(v_plane)

  end do                                                     ; END OF TIME LOOP
end
