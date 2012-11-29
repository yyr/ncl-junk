;    File: wind10.ncl
; Created: Friday, September 22 2011
; License: GPL v3 or later.

load "$nsc/yagUtils.ncl"

begin

  a = addfile("./wrfout_d01_2008-01-02_12:00:00.nc", "r")
  tvalues = (/ 48,72,90/)   ;specify desired timestep outputs must be even

  type = "png"
  out  = "slp_wind10_pan"       ;out put file name

  wks = gsn_open_wks(type,out)

  res = True
  res@Footer = False
  res@gsnSpreadColors = True    ;spread Colors

  mpres  = True  ; Map resources
  pltres = True ; Plot resources
  mpres@mpDataBaseVersion    = "HighRes"
  mpres@mpGeophysicalLineThicknessF = 2.0
  mpres@mpGeophysicalLineColor = "Blue"

  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 750, 850, 2   ;; LOOP NAME
    print("tvalue: " + it)

    print("Working on time: " + times(it))
    res@TimeLabel = times(it)

    u10 = wrf_user_getvar(a,"U10",it)
    v10 = wrf_user_getvar(a,"V10",it)
    slp = wrf_user_getvar(a,"slp",it)

    res@gsnDraw              = False
    res@gsnFrame             = False

    cres = res
    cres@cnFillOn         = False
    cres@cnLevelFlags = True
    cres@gsnPanelRight = True
    cres@InitTime = False
    cres@ContourParameters = (/ 972., 996., 3 /)

    contour = wrf_contour(a,wks,slp,cres)
    delete(cres)

    opts = res
    opts@vcGlyphStyle = "LineArrow"
    opts@vcMonoLineArrowColor = True
    opts@gsnSpreadColors     = True          ; use full colormap
    opts@vcGlyphStyle        = "CurlyVector" ; turn on curly vectors
    opts@InitTime = False
    opts@ValidTime = False
    opts@FieldTitle = "Wind"    ; overwrite Field Title

    pltres@NoTitles = True
    pltres@PanelPlot = True
    pltres@FramePlot = False
    pltres@MainTitlePos= False

    vector = wrf_vector(a,wks,u10(:,:),v10(:,:),opts)
    plot(it) = wrf_map_overlays(a,wks,(/vector,contour/),pltres,mpres)
    delete(vector)

  end do

  pres                = True    ; mod panel plot
  pres@lbLabelStride  = 4       ; skip every other label
  pres@gsnMaximize = True
  pres@gsnMaximize = True
  pres@txString         = "slp and Wind at 10m"
  pres@lbOrientation = "vertical"

  gsn_panel(wks,plot,(/1,noft/),pres)

end
