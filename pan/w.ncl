;;  Author: Yagnesh Raghava Yakkala <hi@yagnesh.org>
;; Created: Wednesday, September 21 2011

import("yag_utils")

begin

  a = set_inputfile()

  type = "pdf"
  pressure = 950.
  out = "vert_wind" + pressure

  tvalues = (/ 47,60,88,94 /)

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"ViBlGrWhYeOrRe")

  res = True
  res@gsnSpreadColors = True
  res@lbLabelBarOn = False           ; turn off individual cb's

  mpres  = True
  pltres = True
  mpres = set_res_highres_coast(mpres)

  times = a->Times

  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 0, 1 ; noft - 1, 1
    print("tvalue: " + tvalues(it))

    print("Working on time: " + chartostring(times(it,:)))
    date_string = chartostring(times(it,5:15))
    res@gsnCenterString = date_string

    w = wrf_user_getvar(a,"W",tvalues(it))
    p  = wrf_user_getvar(a,"pressure",it) ; total pressure
    printVarSummary(w)
    wa = wrf_user_unstagger(w,w@stagger)
    w_plane = wrf_user_intrp3d(wa,p,"h",pressure,0.,False)

    res = set_res_no_frame(res)
    res@cnInfoLabelOn = False        ; turn off contour info label

    opts = res
    opts@cnFillOn         = True
    opts@cnFillColor = True
    opts@ContourParameters = (/ -1.0, 1.4, .3/)
    level = 5
    mpres@gsnMaximize = True

    if (isvar("w_plane"))
      ;; contour = wrf_contour(a,wks,w(level,:,:),opts)
      contour = wrf_contour(a,wks,w_plane(:,:),opts)
      plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
      delete(contour)
    end if
  end do
  pres                = True
  pres@txString         = "Vertical wind" +  pressure + "hPa"
  panelize_2col(wks,plot,pres)
end
