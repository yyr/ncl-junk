;    File: vint.ncl
;  Author: Yagnesh Raghava Yakkala <hi@yagnesh.org>
; Created: Wednesday, September 21 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
; compute vertical integation of a given variable

load "$nsc/yagUtils.ncl"

begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  type = "ps"
  var = "QSNOW"
  out = "vint_" + var       ;out put file name

  tvalues = (/ 47,88,90,92,94,96 /)   ;specify desired timestep outputs must be even
  ; tvalues = tvalues + 96
  wks = gsn_open_wks(type,out)

  noflevels = 33                ; how many layers should be added

  res = True
; res@MainTitle = "Water Vapour Mixing Ration"
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
    print("Record Number: " + tvalues(it))

    print("Working on time: " + times(tvalues(it)))
    res@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots
    ; res@gsnLeftString = times(tvalues(it))   ; Set Valid time to use on plots

    qv = wrf_user_getvar(a,var,tvalues(it))
    qv = qv*1000.
    qv@units = "g/kg"

    dim = dimsizes(qv)
    qv_sum = new((/ dim(1),dim(2) /),typeof(qv))

    qv_sum = qv(1,:,:)
    do z = 1, noflevels, 1   ; z level
      qv_sum(:,:) = qv_sum(:,:) + qv(z,:,:) ;* 1/mean_levels)
    end do

    res@gsnDraw              = False              ; Do not draw plot
    res@gsnFrame             = False              ; Do not advance frame

    opts = res
    res@cnInfoLabelOn = False        ; turn off contour info label
    opts@cnFillOn         = True
    opts@cnFillColor = True

    opts@InitTime = False
    pltres@NoTitles = True
    pltres@PanelPlot = True
    pltres@FramePlot = False
    pltres@MainTitlePos= False

    mpres@gsnMaximize = True
    ; mpres@MainTitlePos= False

    level= 10
    contour = wrf_contour(a,wks,qv_sum(:,:),opts)
    ; contour = wrf_contour(a,wks,qice(level,:,:),opts)
    plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)

  end do

  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 3                ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@gsnMaximize = True

  pres@txString         =  "Sum of " + var + "( " + noflevels + " levels)"; add common title
  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end
