; currently plots snow mixing ratio in a given verticle cross section.
; intention to make any give variable in any given line, hard coded right now

load "$nsc/yagUtils.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

  type = "pdf"

  wks = gsn_open_wks(type,"cs")
  wks2 = gsn_open_wks(type,"cs1")
  gsn_define_colormap(wks,"WhiteYellowOrangeRed")    ; Adds the color table

  planes = (/(/217,378,98,372/),(/252,350,80,301/), (/300,378,56,176/) , \
          (/303,382,62,237/)/)
  plane = new(4,float)
  plane = planes(3,:)

  angle = 0.                    ; intialize
  angle = angle_with_horizontal(plane(0),plane(1),plane(2),plane(3))

  upper = 850.
  lower = 970.

  res = True
  res =set_no_frame_res(res)
  res@gsnLeftString=""
  res@gsnRightString=""

  opts = True                   ; Specifying start and end points
  pltres = True
  FirstTime = True              ; for calculating top level

  res@vpXF             = 0.08                  ; position and sizes
  res@vpYF             = 0.94                  ; for XY plot
  res@vpWidthF = .9
  res@vpHeightF = .4

  times  = wrf_user_list_times(a)          ; Get times in the file
  ntimes = dimsizes(times)                 ; Number of times in the file

  nd = rank_of_file_var(a,"P")

  do it = 96,96

    print("Working on time: " + times(it) )

    th  = wrf_user_getvar(a,"th",it)
    phi = wrf_user_getvar(a,"geopt",it)

    T = wrf_user_getvar(a,"tc",it)
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

;-- calculate phi_diff along the line (geo potential difference between two levels)
    phi_lower = wrf_user_intrp3d(phi,p,"h",lower,0.,opts)
    phi_upper = wrf_user_intrp3d(phi,p,"h",upper,0.,opts)

    phi_lower_line = wrf_user_intrp2d(phi_lower,plane,angle,opts)
    phi_lower_line = where(phi_lower_line.ge.5000,phi_lower_line@_FillValue,phi_lower_line)
    phi_upper_line = wrf_user_intrp2d(phi_upper,plane,angle,opts)

    phi_diff = phi_upper_line - phi_lower_line

    ; project on to the cross section line (to make a plot vertical plane)
    ; uproj will horizontal component and w will be vertical component
    uproj = u_plane*cos(angle) + v_plane*sin(angle)

    T_0_line = wrf_user_intrp2d(T(0,:,:),plane,angle,opts)

    ;;-- calculate the height of the plot  --
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
    opts_xy@cnMissingValPerimOn     = True
    opts_xy@cnMissingValFillColor   = 0
    opts_xy@cnMissingValFillPattern = 11
    opts_xy@tmYLMode                = "Explicit"
    opts_xy@tmYLValues              = fspan(0,zspan,nz)           ; Create tick marks
    opts_xy@tmYLLabels              = sprintf("%.0f",fspan(zmin,zmax,nz))
    opts_xy@tiXAxisFontHeightF      = 0.02
    opts_xy@tiYAxisFontHeightF      = 0.02


; Plotting options for PV
    opts_pv = opts_xy
    opts_pv@pmLabelBarOrthogonalPosF = -0.07
    opts_pv@cnFillOn = True
    opts_pv@gsnSpreadColors = True

    opts_th = opts_xy
    opts_th@cnSmoothingOn = True
    opts_th@cnLineColor = "Blue"
    opts_th@cnInfoLabelOn = False
    opts_th@gsnContourLineThicknessesScale = 2.0
    opts_th@cnLineLabelBackgroundColor = "white"
    opts_th@cnInfoLabelOn = False
    opts_th@cnLabelDrawOrder  = "PostDraw"
    opts_th@cnInfoLabelOrthogonalPosF = 0.00

; Vertical Velocity

    opts_v = res
    opts_v = set_no_frame_res(opts_v)
    opts_v = set_vc_res(opts_v)
    opts_v@vcRefMagnitudeF = 10.

    contour_th = gsn_csm_contour(wks,th_plane(0:zmax_pos,:),opts_th)
    contour_qs = gsn_csm_contour(wks,qs_plane(0:zmax_pos,:),opts_pv)
    vector = gsn_vector(wks,uproj(0:zmax_pos,:),w_plane(0:zmax_pos,:),opts_v)

    overlay(contour_th,contour_qs)
    overlay(contour_th,vector)

    res_xy = True
    res_xy = set_no_frame_res(res_xy)
    res_xy@vpXF             = 0.08                  ; position and sizes
    res_xy@vpYF             = 0.48                  ; for XY plot
    res_xy@vpWidthF = 0.9
    res_xy@vpHeightF = 0.22
    res_xy@gsnMaximize = True
    res_xy@xyLineColor = "orange"

    res_xy2 = res_xy
    res_xy2@vpYF             = 0.24                  ; for XY plot
    res_xy2@tiYAxisString = "SAT"
    res_xy2@xyLineColor = "blue"


    plot2 = gsn_csm_xy2(wks2,ispan(0,dim_len0(phi_diff),1),phi_diff,T_0_line,res_xy,res_xy2)
    plot2 = gsn_csm_xy2(wks2,ispan(0,dim_len0(phi_diff),1),phi_diff,T_0_line,res_xy,res_xy2)
;    plot3 = gsn_csm_xy2(wks,phi_diff,T_0_line,res_xy,res_xy2)

    draw(contour_th)
    draw(plot2)
    frame(wks)
    frame(wks2)

    ; pnlres = True
    ; pnlres@gsnPanelFigureStrings = (/"a", "b", "c" ,"d"/)
    ; pnlres@amJust   = "TopLeft"
    ; pnlres@gsnMaximize = True
    ; maximize_output(wks,pnlres)

    ; pnlres@gsnPanelDebug = True
    ; gsn_panel(wks,(/contour_th,plot2,plot3/),(/3,1/),pnlres)

  end do                                                     ; END OF TIME LOOP
end
