import("yag_utils")

begin
  a = set_inputfile()
  type = "pdf"

  time = 64
  wks = gsn_open_wks(type,"cs_th")

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

    th  = wrf_user_getvar(a,"th",it)
    T = wrf_user_getvar(a,"tc",it)
    p  = wrf_my_getvar(a, "pressure",it)

    th_plane = wrf_user_intrp3d(th,p,"v",plane,angle,True)
;    T_plane =  wrf_user_intrp3d(T,p,"v",plane,angle,True)

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

    opts_th = opts_xy
    opts_th = set_res_cn(opts_th)
    opts_th@gsnContourLineThicknessesScale = 2.0
    opts_th@cnLabelDrawOrder  = "PostDraw"
    opts_th@cnInfoLabelOrthogonalPosF = 0.00

    date_string = chartostring(times(it,5:15))
    opts_th@gsnCenterString = date_string


    set_res_cn_limits(opts_th,265.,290.,.2)
    contour_T = gsn_csm_contour(wks,th_plane(0:zmax_pos,:),opts_th)

   draw(contour_T)
   frame(wks)
  end do
end
