; currently plots snow mixing ratio in a given verticle cross section.
; intention to make any give variable in any given line, hard coded right now

import("yag_utils")

begin
  a = set_inputfile()
  type = "pdf"

  thin = 5
  time = 95
  out = "cs_" + time
;  out = "cs"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"WhiteYellowOrangeRed")    ; Adds the color table

  planes = (/(/217,378,98,372/),(/252,350,80,301/), (/300,378,56,176/) , \
             (/303,382,62,237/),(/236,288,130,219/)/)

  plane = new(4,float)
  plane = planes(3,:)

  ; plane = (/263,104,305,158/)
  ; plane = (/303,62,382,237/)

  angle = 0.                    ; intialize
  angle = angle_with_horizontal(plane(0),plane(1),plane(2),plane(3))

  res = True
  set_res_aspectratio_manual(res,0.8,0.3)
  FirstTime = True              ; for calculating top level
  times  = wrf_user_list_times(a)          ; Get times in the file

  do it = time, time
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
    w_plane = w_plane * 5.

    ; project on to the cross section line (to make a plot vertical plane)
    ; uproj will horizontal component and w will be vertical component
    uproj = u_plane*cos(angle) + v_plane*sin(angle)
    xinter = 50.

    if ( FirstTime ) then
      zmax = 550.
      zz = wrf_user_intrp3d(p,p,"v",plane,angle,True)

      zmin = 1000
      nice_levs = floor((zmin-zmax)/xinter)*xinter
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
      nz = floattoint((zmin-zmax)/xinter+1)
      FirstTime = False
    end if

    opts_xy                         = res
    opts_xy@tiYAxisString           = "Pressure (hPa)"
    opts_xy@tiXAxisString           = ""
    opts_xy@cnMissingValPerimOn     = True
    opts_xy@cnMissingValFillColor   = 0
    opts_xy@cnMissingValFillPattern = 11
    opts_xy@tmYLMode                = "Explicit"
    opts_xy@tmYLValues              = fspan(0,zspan,nz)           ; Create tick marks
    opts_xy@tmYLLabels              = sprintf("%.0f",fspan(zmin,zmax,nz))
    opts_xy@tiXAxisFontHeightF      = 0.02
    opts_xy@tiYAxisFontHeightF      = 0.02
    opts_xy@tfDoNDCOverlay = True
    opts_xy@tmXTOn         = False
    opts_xy@tmYROn         = False

    ;; Change xaxis to km from grid.
    xmax_pos = dim_len1(w_plane)
    xmax = xmax_pos * angle * 1.5 ; turn into km ( * angle * grid_lenth_in_km)

    nice_xmax=(floor(xmax/xinter)+1)*xinter
    nx = floattoint(nice_xmax/xinter + 1) ; NOTE: this is just type change, not value correction.
    xtick_pos_vals = sprintf("%.0f",ispan(0,floattoint(nice_xmax), floattoint(xinter)))

    nice_xmax_pos = floor(xmax_pos/nx+1) * nx + 4 ; here "4" is workaround for error got in decimal correction.
    xtick_pos = fspan(0,nice_xmax_pos,nx)
    ; print(xtick_pos + " " + xtick_pos_vals)

    opts_xy@tmXBMode                = "Explicit"
    opts_xy@tmXBValues = xtick_pos
    opts_xy@tmXBLabels = xtick_pos_vals

; Plotting options for PV
    opts_pv = opts_xy
    opts_pv@cnFillOn = True
    opts_pv@cnLevelFlags = "LineOnly"
    opts_pv@cnLevelFlag = False
    opts_pv@cnLineLabelsOn = False
    set_res_cn_limits(opts_pv,0.0002,0.002,.0002)

    opts_pv = set_res_lb(opts_pv)
    opts_pv@lbLabelStride = 4
    opts_pv@pmLabelBarOrthogonalPosF = -0.1

; Plotting options for TH
    opts_th = opts_xy
    opts_th@gsnContourLineThicknessesScale = 2.0
    opts_th@pmLabelBarOrthogonalPosF = -0.1

    opts_th@cnFillOn = True
    opts_th@cnSmoothingOn = True
    opts_th@cnLineColor = "Blue"
    opts_th@cnInfoLabelOn = True
    opts_th@cnLineLabelBackgroundColor = "white"
    opts_th@cnInfoLabelOn = False
    opts_th@cnLabelDrawOrder  = "PostDraw"
    opts_th@cnInfoLabelOrthogonalPosF = 0.00
    set_res_cn_limits(opts_th,265,290,1)
    opts_th = set_res_lb(opts_th)

; Plotting options for v
    opts_v = opts_xy
    opts_v = set_res_no_frame(opts_v)
    opts_v = set_res_vc(opts_v)
    opts_v = set_res_vc_anno(opts_v)
    opts_v@vcLineArrowColor = "Blue"

;    drawNDCGrid(wks)
    opts_pv@gsnFrame         = False
    opts_pv@vpXF             = 0.15
    opts_pv@vpYF             = 0.9


    contour_qs = gsn_csm_contour(wks,qs_plane(0:zmax_pos,:),opts_pv)
    vector = gsn_vector(wks,uproj(0:zmax_pos:thin,::thin), \
                        w_plane(0:zmax_pos:thin,::thin),opts_v)
    overlay(contour_qs,vector)

    ; put a) on top left
    txres = True
    txres@txBackgroundFillColor = "white"
    txres@txFont                = "helvetica"
    txres@txFontHeightF = 0.02
    txres@txPerimOn  = True
    txid1 = gsn_create_text(wks, "a)", txres)

    amres = True
    amres@amParallelPosF   = -0.44    ; This is the right edge of the plot.
    amres@amOrthogonalPosF = -0.2    ; This is the bottom edge of the plot.
    amres@amJust           = "BottomRight"
    annoid1 = gsn_add_annotation(contour_qs, txid1, amres)
    draw(contour_qs)

    opts_th@gsnFrame         = False
    opts_th@vpXF             = 0.15
    opts_th@vpYF             = 0.45

    gsn_define_colormap(wks,"ncl_default")    ; Adds the color table
    contour_th = gsn_csm_contour(wks,th_plane(0:zmax_pos,:),opts_th)

    ; put b) on top left
    txid1 = gsn_create_text(wks, "b)", txres)
    annoid1 = gsn_add_annotation(contour_th, txid1, amres)

    draw(contour_th)
  end do
end
