;;    File: w_panel.ncl
;;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
;; Created: Wednesday, September 21 2011
;; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;;

;; Description:
;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

  type = "ps"
  pressure = 950.               ;which level you want to plot
  out = "vert_wind" + pressure       ;out put file name

  tvalues = (/ 47,60,88,94 /)   ;specify desired timestep outputs must be even

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"ViBlGrWhYeOrRe")   ; overwrite the .hluresfile color map

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

  do it = 0, noft - 1, 1   ;; LOOP NAME
    print("tvalue: " + tvalues(it))


    print("Working on time: " + times(tvalues(it)))
    res@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots
    ;; res@gsnLeftString = times(tvalues(it))   ; Set Valid time to use on plots

    w = wrf_user_getvar(a,"W",tvalues(it))

    p  = wrf_user_getvar(a,"pressure",it) ; total pressure
    printVarSummary(w)
    wa = wrf_user_unstagger(w,w@stagger)

    w_plane = wrf_user_intrp3d(wa,p,"h",pressure,0.,False)

    res@gsnDraw              = False              ; Do not draw plot
    res@gsnFrame             = False              ; Do not advance frame
    res@cnInfoLabelOn = False        ; turn off contour info label

    opts = res
    opts@cnFillOn         = True
    opts@cnFillColor = True
    opts@ContourParameters = (/ -1.0, 1.4, .3/)
    opts@PlotLevelID      = "Eta Level  " + pressure
    opts@InitTime = False
    level =5

    pltres@NoTitles = True
    pltres@PanelPlot = True
    pltres@FramePlot = False
    pltres@MainTitlePos= False

    mpres@gsnMaximize = True

    if (isvar("w_plane"))
      ;; contour = wrf_contour(a,wks,w(level,:,:),opts)
      contour = wrf_contour(a,wks,w_plane(:,:),opts)
      plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
      delete(contour)
    end if
  end do

  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 6                ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@gsnMaximize = True

  pres@txString         = "Vertical wind" +  pressure + "hPa"     ; add common title
  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end
