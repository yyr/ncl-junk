;    File: div10m.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Thursday, October  6 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

load "$nsc/yagUtils.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  type = "pdf"
  out = "div"     ;out put file name

  tvalues = (/71, 82, 95, 119 /)

  wks = gsn_open_wks(type,out)
  gsn_reverse_colormap(wks)

  res = True
  res = set_no_frame_res(res)

  res@cnInfoLabelOn = False        ; turn off contour info label

  res@gsnSpreadColors = True    ;spread Colors
  res@lbLabelBarOn        = False           ; turn off individual cb's

  pltres = True ; Plot resources
  mpres  = True  ; Map resources
  mpres@mpDataBaseVersion    = "HighRes"
  mpres@mpGeophysicalLineThicknessF = 2.0
  mpres@mpGeophysicalLineColor = "Blue"


  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

  noft = dim_len0(tvalues)
  plot = new(noft,graphic)

  do it = 0, noft - 1, 1   ; LOOP NAME

    print("tvalue: " + tvalues(it))
    print("Working on time: " + times(tvalues(it)))

    u = a->U10(tvalues(it),:,:)
    v = a->V10(tvalues(it),:,:)
    dim=dimsizes(u)

    dx = 1500                  ; horizontal grid distance in x direction

    div=new( (/ dim(0), dim(1) /) , typeof(u))

    div = uv2dvG(u,v)
    div = div * dx

    res@gsnDraw              = False              ; Do not draw plot
    res@gsnFrame             = False              ; Do not advance frame
    res@cnInfoLabelOn = False        ; turn off contour info label
    res@lbLabelBarOn         = False               ; turn off the label bar

    opts = res
    opts@cnFillOn         = True
    opts@cnFillColor = True
    opts@InitTime = False
    opts@ContourParameters = (/-.2, 0.2 , .1 /)

    ;;-- map res  --
    mpres@NoHeaderFooter = True
    opts@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots

    ;;-- plot res  --
    pltres@NoTitles = True
    pltres@PanelPlot = True
    pltres@FramePlot = False
    pltres@gsnLeftString = times(tvalues(it))   ; Set Valid time to use on plots

    contour = wrf_contour(a,wks,div,opts)
    plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
    delete(contour)

  end do

  pres                = res              ; mod panel plot
  pres@lbLabelStride  = 4         ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@gsnMaximize = True
  pres@gsnPanelLabelBar = True
  pres@lbOrientation = "vertical"

  pres@gsnPanelDebug = True

  gsn_panel(wks,plot,(/2,noft/2/),pres)        ; create panel plot

end
