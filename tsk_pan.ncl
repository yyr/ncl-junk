;;    File: panel_t.ncl
;;  Author: Yagnesh Raghava Yakkala <hi@yagnesh.org>
;; Created: Friday, September  9 2011
;; License: GPL v3 or later.
;;

load "$nsc/yagUtils.ncl"

begin
  a = set_inputfile()

  type = "ps"
  pressure = 850.                      ;which level you want to plot
  out = "tsk"                          ;out put file name
  tvalues = (/ 47, 78, 82, 86, 90,94/) ;specify desired timestep outputs must be even

  wks = gsn_open_wks(type,out)
  res = True

  pltres = True                        ; Plot resources
  mpres = set_high_res_coast(True)

  times  = wrf_user_list_times(a)      ; get times in the file
  ntimes = dimsizes(times)             ; number of times in the file

  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 0, noft - 1, 1
    print("tvalue: " + tvalues(it))

    print("Working on time: " + times(it) )
    res@TimeLabel = times(tvalues(it)) ; Set Valid time to use on plots

    tsk = wrf_user_getvar(a,"TSK",tvalues(it))

    res@gsnDraw              = False   ; Do not draw plot
    res@gsnFrame             = False   ; Do not advance frame
    res@cnInfoLabelOn = False          ; turn off contour info label

    opts = res
    opts@cnFillOn         = True
    opts@ContourParameters = (/ 265., 280., 0.5 /)
    opts@cnFillColor = True

    mpres@NoHeaderFooter = True
    contour = wrf_contour(a,wks,tsk,opts)

    plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
    delete(contour)
  end do
  pres                = True           ; mod panel plot
  pres@txString         = "TSK"
  panelize_3col(wks,plot,pres)
end
