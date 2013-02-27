;    File: hov.ncl
;  Author: Yagnesh Raghava Yakkala <hi@yagnesh.org>
; Created: Monday, November 14 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
; ho

load "$nsc/yagUtils.ncl"

begin

  directories=(/"/home/yagnesh/WRFMPI/WRFV3/test/bd/res" \
                , "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_sak/d3" \
                , "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_hok/d3" \
                , "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_hok_sak/d3" \
                , "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_topo/d3" \
                , "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_topo_saka/d3" \
                /)


  type = "pdf"
  wks = gsn_open_wks(type,"hov")
  gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")

  varname = "QSNOW"

  planes = (/(/217,378,98,372/),(/252,350,80,301/), (/300,378,56,176/) , \
             (/303,382,62,237/)/)
  plane = new(4,float)
  plane = planes(3,:)

  plot = new(dim_len0(directories),graphic)

  do i = 0, dim_len0(directories) - 1, 1

    a = addfile(directories(i)+"/wrfout_d03_2008-12-25_00:00:00.nc","r")
    system("echo $(pwd)" )

    ; get time information and strip out the day and hour
    times_in_file = a->Times

    dimt = filevardimsizes(a,varname)
    nt = dim_len0(times_in_file)

    st_time = 48
    wgted_var = new((/ nt - st_time ,dimt(2),dimt(3)/),float)

    times = new(nt,string)
    do it = st_time, nt-1, 1   ;; times
      dummy = it - st_time
      wgted_var(dummy,:,:) = wrf_user_getvar_weighted_sum(a,varname,it)

      times(dummy) = chartostring(times_in_file(it,8:12))
      ; print("working with time:" + times(dummy))
      dummy = dummy + 1
    end do

    wgted_var = wgted_var * 1000.
    dims = dimsizes(wgted_var)

    opts = True                             ; start and end point not supplied
    angle = 0.                    ; intialize
    angle = angle_with_horizontal(plane(0),plane(1),plane(2),plane(3))

    t_plane = wrf_user_intrp2d(wgted_var,plane,angle,opts)

    res = True
    res@gsnDraw = False
    res@gsnFrame = False
    res@trYReverse          = True                ; reverse y axis

    res@tmYLMode       = "Explicit"    ; Define own tick mark labels.
    res@tmYLValues     =  fspan(0,dim_len0(times),dim_len0(times))         ; location of explicit labels
    res@tmYLLabels     = times         ; labels are the locations
    res@tmYLMaxTicks = 10
    res@tmYLLabelStride = 12
    res@tmYLMinorOn = False
    res@tmYROn         = False         ; turn off the top tick marks
    res@tmYLLabelsOn = False
    res@tmYLLabelFontHeightF = 0.025
    res@cnInfoLabelOn = False

    res@tmYLMaxTicks = 16

    res@cnInfoLabelOn = False
    res@cnLevelFlag = "LineOnly"
    res@cnLinesOn = False
    res@cnFillOn = True
    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels = fspan(0.4,2.6,12)

    res@lbLabelBarOn = False
    res@tmXBLabelFontHeightF = 0.025
    ; res@tmXBLabelsOn = False

    if ( any(i .eq. (/0,3/)) ) then
      res@tmYLLabelsOn = True
    end if

;    plot(i) = gsn_csm_hov(wks,t_plane,res)
    plot(i) = gsn_csm_hov(wks,t_plane(:,0:130),res)
    res@cnFillOn = False
    delete(res@cnLevels)
    res@cnLevels = (/0.4,0.6/)
    dummy1 = gsn_csm_hov(wks,t_plane(:,0:130),res)

    overlay(plot(i),dummy1)
    delete(dummy1)
    delete(res)

  end do

; Panelize
  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 2                ; skip every other label
  pres@gsnPanelBottom = 0.1              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@gsnMaximize = True
  pres@gsnPanelFigureStrings = (/"a", "b", "c" ,"d", "e", "f"/)
  pres@gsnPanelFigureStringsFontHeightF = .028
  pres@amJust   = "TopRight"

;  panel_style = panel_sensibly(dim_len0(plot))
  gsn_panel(wks,plot,(/2, dim_len0(directories)/2 /),pres)        ; create panel plot

end
;;; hov.ncl ends here
