load "$nsc/yagUtils.ncl"
import("shea_util")

begin
  directories=(/"/home/yagnesh/WRFMPI/WRFV3/test/bd/res" \
                , "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_sak/d3" \
                , "/home/yagnesh/wrf/run/notopsak_20081225/d3/" \
                , "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_hok/d3" \
                , "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_topo/d3" \
                , "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_hok_sak/d3" \
                /)

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
;  a = set_inputfile()
    a = addfile(directories(i)+"/wrfout_d03_2008-12-25_00:00:00.nc","r")
    times_in_file = a->Times
    announce(directories(i))

    dimt = filevardimsizes(a,varname)
    nt = dim_len0(times_in_file)

    st_time = 48
    wgted_var = new((/ nt - st_time ,dimt(2),dimt(3)/),float)
    times = new(nt,string)

;   wgted_var(0,:,:) = wrf_user_getvar_weighted_sum(a,varname,48)

    do it = st_time, nt-1, 1   ;; times
      dummy = it - st_time
      wgted_var(dummy,:,:) = wrf_user_getvar_weighted_sum(a,varname,it)
;      wgted_var(dummy,:,:) = wgted_var(0,:,:)

      times(dummy) = chartostring(times_in_file(it,8:12))
      print("working with time:" + times(dummy))
      dummy = dummy + 1
    end do

    drawn_times = nt-1 - st_time
    wgted_var = wgted_var * 1000.

    angle = 0.                    ; intialize
    angle = angle_with_horizontal(plane(0),plane(1),plane(2),plane(3))
    t_plane = wrf_user_intrp2d(wgted_var,plane,angle,True)

    ticks = ispan(0,drawn_times,10) ; positions to draw ticks

    res = True
    res = set_res_no_frame(res)
    res = set_res_cn(res)
    res@lbLabelBarOn = False
    res@cnLinesOn = False
    set_res_cn_limits(res, 0.004, 0.026, .002 )

    res@trYReverse          = True                ; reverse y axis
    res@tmYLMode       = "Explicit"    ; Define own tick mark labels.
    res@tmYLValues     = ticks
    res@tmYLLabels     = times(ticks)         ; labels are the locations
    res@tmYROn         = False         ; turn off the top tick marks
    res@tmYLLabelFontHeightF = 0.025
    res@tmXBLabelFontHeightF = 0.025
    plot(i) = gsn_csm_hov(wks,t_plane(:,:),res)
;    plot(i) = gsn_csm_hov(wks,t_plane(:,0:140),res)

  end do
  pres = True
  pres@lbLabelStride  = 2                ; skip every other label
  pres = set_res_panel(pres)
  pres@gsnPanelFigureStrings = (/"CTRL", "NSAK", "NTOPSAK", "NHOK", "NTOPHOK", "NHOKSAK"/)
  panelize_2col(wks,plot,pres)

end
;;; hov.ncl ends here
