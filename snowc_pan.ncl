;;    File: panel_t.ncl
;;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
;; Created: Friday, September  9 2011
;; License: GPL v3 or later.
;;

load "$nsc/yagUtils.ncl"

begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  type = "ps"
  out = "snowc"       ;out put file name

  tvalues = (/ 0,47,90,92,94,96 /)   ;specify desired timestep outputs must be even

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

  do it = 0, noft - 1, 1   ;; LOOP NAME
    print("tvalue: " + tvalues(it))


    print("Working on time: " + times(tvalues(it)))
    res@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots

    if(isfilevar(a,"SNOWC"))
      snowc = wrf_user_getvar(a,"SNOWC",tvalues(it))
    end if

    res@gsnDraw              = False              ; Do not draw plot
    res@gsnFrame             = False              ; Do not advance frame

    res@cnInfoLabelOn = False        ; turn off contour info label

    opts = res
    opts@cnFillOn         = True
    opts@cnFillColor = True
    opts@ContourParameters = (/ 0., 1.,0.5 /)
    opts@InitTime = False
    ;; opts@ValidTime = False
    level =5

    pltres@NoTitles = True
    pltres@PanelPlot = True
    pltres@FramePlot = False
    pltres@MainTitlePos= False

    mpres@gsnMaximize = True
    ;; mpres@MainTitlePos= False

    if (isvar("snowc"))
      ;; contour = wrf_contour(a,wks,snowc(level,:,:),opts)
      contour = wrf_contour(a,wks,snowc(:,:),opts)
      plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
      delete(contour)
    end if

  end do

  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 2                ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@gsnMaximize = True

  pres@txString         = "Snow Coverage"     ; add common title
  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end
