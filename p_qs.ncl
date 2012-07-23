load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$nsc/WRFUserARW.ncl"
load "$nsc/yagUtils.ncl"

begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

 tvalues = (/71, 82, 95, 119 /)   ;specify desired timestep outputs must be even
; tvalues = (/71, 82 /)   ;specify desired timestep outputs must be even

  type = "png"
  out = "qs"

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"temp_19lev")   ; overwrite the .hluresfile color map

  varname = "QSNOW"
  noflevels = 32                ; how many layers should be added

  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  res = True
  res@Footer = False
  res@gsnDraw              = False              ; Do not draw plot
  res@gsnFrame             = False              ; Do not advance frame

  do it = 0, noft - 1, 1   ; LOOP NAME

    vt = tvalues(it)
    print("working with: " + times(vt))


    wgted_var = wrf_user_getvar_weighted_sum(a,varname,vt)
    wgted_var = wgted_var * 1000. ;
    wgted_var@units = "g"

    res@TimeLabel = times(vt)   ; Set Valid time to use on plots

    opts = res
    opts@gsnMaximize = True
    opts@AspectRatio = 1.2
;    opts = set_zoom_in(a,178,54,389,325,opts)

;__contour map _______________________________________________________________

    optsW =  opts
    optsW@ContourParameters = (/ 0., 2.6, .4 /)
    optsW@InitTime = False
    contour = wrf_contour(a,wks,wgted_var,opts)
    delete(optsW)


    optsT = opts
    optsT@cnFillOn         = True
    optsT@cnFillColor = True
    optsT@ContourParameters = (/ 260.,280., 0.5 /)
    optsT@InitTime = False
    optsT@lbLabelBarOn = False
    optsT@cnInfoLabelOn = False        ; turn off contour info label

    t2 = wrf_user_getvar(a,"T2",vt)
    contour_t = wrf_contour(a,wks,t2,optsT)
    delete(optsT)

    pltres = True ; Plot resources
    pltres@NoTitles = True
    pltres@MainTitlePos= False
    pltres@PanelPlot = True
    pltres@FramePlot = False

    mpres  = True  ; Map resources
    mpres@mpDataBaseVersion    = "HighRes"
    mpres@mpGeophysicalLineThicknessF = 2.0
    mpres@mpGeophysicalLineColor = "Blue"

;    mpres = set_zoom_in(178,54,389,325,mpres)

    plot(it) = wrf_map_overlays(a,wks,(/contour_t,contour/),pltres,mpres)
    delete(pltres)
    delete(mpres)

  end do

  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 4                ; skip every other label
  pres@gsnPanelBottom = 0.1              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar
  pres@gsnMaximize = True
;  pres@lbOrientation = "vertical"

  pres@txString         = "Integraded column Snow over SST"
  gsn_panel(wks,plot,(/2, noft/2 /),pres)        ; create panel plot


end
