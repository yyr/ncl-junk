;;    File: panel_t.ncl
;;  Author: Yagnesh Raghava Yakkala <hi@yagnesh.org>
;; Created: Friday, September  9 2011
;; License: GPL v3 or later.
;;  You should get a copy from <http://www.gnu.org/licenses/gpl.html>
;;

load "$nsc/yagUtils.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

  type = "ps"
  pressure = 850.               ;which level you want to plot
  out = "tsk"       ;out put file name

  tvalues = (/ 47, 78, 82, 86, 90,94/)   ;specify desired timestep outputs must be even

  wks = gsn_open_wks(type,out)

  res = True
  ;; res@MainTitle = "Water Vapour Mixing Ration"
  res@Footer = False
  res@gsnSpreadColors = True    ;spread Colors
  res@lbLabelBarOn        = False           ; turn off individual cb's

  mpres  = True  ; Map resources
  pltres = True ; Plot resources
  mpres@mpDataBaseVersion    = "HighRes"
  mpres@mpGeophysicalLineThicknessF = 2.0

  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 0, noft - 1, 1   ;; LOOP NAME
    print("tvalue: " + tvalues(it))

    print("Working on time: " + times(it) )
    res@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots

    tsk = wrf_user_getvar(a,"TSK",tvalues(it))

    res@gsnDraw              = False              ; Do not draw plot
    res@gsnFrame             = False              ; Do not advance frame
    res@cnInfoLabelOn = False        ; turn off contour info label

    opts = res
    opts@cnFillOn         = True
    opts@ContourParameters = (/ 265., 280., 0.5 /)
    opts@cnFillColor = True
    opts@InitTime = False

    pltres@NoTitles = True
    pltres@PanelPlot = True
    pltres@FramePlot = False

    mpres@NoHeaderFooter = True

    contour = wrf_contour(a,wks,tsk,opts)

    plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
    delete(contour)
  end do

end
