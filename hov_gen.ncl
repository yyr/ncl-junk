import("yag_utils")

begin
  directories=(/"wrf/run/20080117/d3"/)

  type = "pdf"
;  type = "X11"
  wks = gsn_open_wks(type,"hov")
  gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
  varname = "QSNOW"

  planes = (/(/236,378,130,372/),(/252,350,80,301/), (/300,378,56,176/) , \
             (/303,382,62,237/),(/236,288,130,219/)/)

  plane = new(4,float)
  plane = planes(3,:)
  plot = new(dim_len0(directories),graphic)


  do i = 0, dim_len0(directories) - 1, 1
    a = set_inputfile()
;    a = addfile(directories(i)+"/wrfout_d03_2008-12-25_00:00:00.nc","r")
    times_in_file = a->Times
    announce(directories(i))

    dimt = filevardimsizes(a,varname)
    nt = dim_len0(times_in_file)

    st_time = 0
    wgted_var = new((/ nt - st_time ,dimt(2),dimt(3)/),float)

    times = new(nt,string)
    do it = st_time, nt-1, 1   ;; times
      dummy = it - st_time
      wgted_var(dummy,:,:) = wrf_user_getvar_weighted_sum(a,varname,it)
      times(dummy) = chartostring(times_in_file(it,8:12))
;      print("working with time:" + times(dummy))
      dummy = dummy + 1
    end do

    drawn_times = nt-1 - st_time
    angle = 0.                    ; intialize
    angle = angle_with_horizontal(plane(0),plane(1),plane(2),plane(3))
    t_plane = wrf_user_intrp2d(wgted_var,plane,angle,True)

    ticks = ispan(0,drawn_times,10) ; positions to draw ticks

    res = True
    res = set_res_no_frame(res)
    res = set_res_cn(res)
    res@lbLabelBarOn = False
    res@cnLinesOn = False
    set_res_cn_limits(res, 0., 15., 1)

    res@trYReverse          = True                ; reverse y axis
    res@tmYLMode       = "Explicit"    ; Define own tick mark labels.
    res@tmYLValues     = ticks
    res@tmYLLabels     = times(ticks)         ; labels are the locations
    res@tmYROn         = False         ; turn off the top tick marks
    res@tmYLLabelFontHeightF = 0.025
    res@tmXBLabelFontHeightF = 0.025

    ;
    xinter = 50.                  ; km
    xmax_pos = dim_len1(t_plane)
    xmax = xmax_pos * angle * 1.5 ; turn into km ( * angle * grid_lenth_in_km)

    nice_xmax=(floor(xmax/xinter)+1)*xinter
    nx = floattoint(nice_xmax/xinter + 1) ; NOTE: this is just type change, not value correction.
    xtick_pos_vals = sprintf("%.0f",ispan(0,floattoint(nice_xmax), floattoint(xinter)))

    nice_xmax_pos = floor(xmax_pos/nx+1) * nx + 4 ; here "4" is workaround for error got in decimal correction.
    xtick_pos = fspan(0,nice_xmax_pos,nx)
    ; print(xtick_pos + " " + xtick_pos_vals)

    res@tmXBMode                = "Explicit"
    res@tmXBValues = xtick_pos
    res@tmXBLabels = xtick_pos_vals
    plot(i) = gsn_csm_hov(wks,t_plane(:,:),res)
    draw(wks)
    frame(wks)

  end do
end
;;; hov.ncl ends here
