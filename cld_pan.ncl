; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: panel_t.ncl
; Created: Friday, September  9 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
;

load "$nsc/yagUtils.ncl"

begin

  a = set_inputfile()

  type = "ps"
  pressure = 900.               ;which level you want to plot
  out = "cld_" + pressure       ;out put file name

  tvalues = (/ 47,88,90,92,94,96 /)   ;specify desired timestep outputs must be even
  wks = gsn_open_wks(type,out)

  res = True
  res@Footer = False
  res@gsnSpreadColors = True
  res@lbLabelBarOn        = False

  mpres  = True
  pltres = True
  mpres = set_high_res_coast(mpres)

  times  = wrf_user_list_times(a)  ; get times in the file

  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 0, noft - 1, 1   ; LOOP NAME
    print("tvalue: " + tvalues(it))

    print("Working on time: " + times(tvalues(it)))
    res@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots

    if(isfilevar(a,"QCLOUD"))
      qc = wrf_user_getvar(a,"QCLOUD",tvalues(it))
      qc = qc*1000.
      qc@units = "g/kg"
    end if

    p  = wrf_user_getvar(a,"pressure",it) ; total pressure
    qc_plane = wrf_user_intrp3d(qc,p,"h",pressure,0.,False)

    res@gsnDraw              = False              ; Do not draw plot
    res@gsnFrame             = False              ; Do not advance frame

    res@cnInfoLabelOn = False        ; turn off contour info label

    opts = res
    opts@cnFillOn         = True
    opts@cnFillColor = True
    opts@ContourParameters = (/ 0., .7, .03 /)
    opts@PlotLevelID      = "Eta Level  " + pressure
    opts@InitTime = False
    level =5

    pltres@NoTitles = True
    pltres@PanelPlot = True
    pltres@FramePlot = False
    pltres@MainTitlePos= False

    mpres@gsnMaximize = True

    if (isvar("qc_plane"))
      ; contour = wrf_contour(a,wks,qc(level,:,:),opts)
      contour = wrf_contour(a,wks,qc_plane(:,:),opts)
      plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
      delete(contour)
    end if
  end do

  pres                = True              ; mod panel plot
  pres@txString         = "Cloud mixing ratio g/kg at " +  pressure + "hPa"     ; add common title
  panelize_2col(wks,plot,pres)
end
