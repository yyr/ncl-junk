;    File: panel_t.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Friday, September  9 2011
; License: GPL v3 or later.  <http://www.gnu.org/licenses/gpl.html>

load "$nsc/yagUtils.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-23_00:00:00.nc","r")
  ; a = addfile("./wrfout_d03_2008-02-11_00:00:00.nc","r")
  ; type = "x11"
  type = "ps"
  pressure = 900.               ;which level you want to plot
  out = "qsnow_" + pressure       ;out put file name

  tvalues = (/ 47,88,90,92,94,96 /)   ;specify desired timestep outputs must be even
  ; tvalues = tvalues + 96


  wks = gsn_open_wks(type,out)

  res = True

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

  do it = 0, noft - 1, 1   ; LOOP NAME

    print("tvalue: " + tvalues(it))
    print("Working on time: " + times(tvalues(it)))

    if(isfilevar(a,"QSNOW"))
      qv = wrf_user_getvar(a,"QSNOW",tvalues(it))
      qv = qv*1000.
      qv@units = "g/kg"
    end if

    p  = wrf_user_getvar(a,"pressure",it) ; total pressure
    qv_plane = wrf_user_intrp3d(qv,p,"h",pressure,0.,False)
    ; printVarSummary(qv_plane)

    res@gsnDraw              = False              ; Do not draw plot
    res@gsnFrame             = False              ; Do not advance frame
    res@cnInfoLabelOn = False        ; turn off contour info label
    res@gsnLeftString = times(tvalues(it))   ; Set Valid time to use on plots

    opts = res
    opts@cnFillOn         = True
    opts@cnFillColor = True
    opts@ContourParameters = (/ 0.5, 2.5, .07 /)
    opts@PlotLevelID      = "Eta Level  " + pressure
    opts@InitTime = False
    ; opts@ValidTime = False
    level = 5

    pltres@NoTitles = True
    pltres@PanelPlot = True
    pltres@FramePlot = False
    pltres@MainTitlePos= False

    mpres@gsnMaximize = True
    ; mpres@MainTitlePos= False

    contour = wrf_contour(a,wks,qv_plane(:,:),opts)
    plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
    delete(contour)

  end do

  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 6                ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@gsnMaximize = True

  pres@txString         = "Snow mixing ratio g/kg at " +  pressure + "hPa"     ; add common title
  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end
