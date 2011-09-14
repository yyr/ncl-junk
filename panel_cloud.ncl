;; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;;    File: panel_t.ncl
;;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
;; Created: Friday, September  9 2011
;; Licence: GPL v3 or later.
;;  You should get a copy from <http://www.gnu.org/licenses/gpl.html>
;;

;; Description:
;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
 ;; a = addfile("./wrfout_d03_2008-02-11_00:00:00.nc","r")
  ;; type = "x11"
  type = "ps"

  ;; -------------
  pressure = 850.               ;which level you want to plot
  ;; -------------
  out = "cld_" + pressure

  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"BlWhSmall")   ; overwrite the .hluresfile color map


  res = True
  res@MainTitle = "Water Vapour Mixing Ration"
  res@Footer = False
  res@gsnSpreadColors = False    ;spread Colors


  mpres  = True  ; Map resources
  pltres = True ; Plot resources
  mpres@mpDataBaseVersion    = "HighRes"
  mpres@mpGeophysicalLineThicknessF = 2.0

  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

  do it = 47, ntimes-1, 2  ;; LOOP NAME

    print("Working on time: " + times(it) )
    res@TimeLabel = times(it)   ; Set Valid time to use on plots

    if(isfilevar(a,"QVAPOR"))
      qv = wrf_user_getvar(a,"QVAPOR",it)
      qv = qv*1000.
      qv@units = "g/kg"
    end if

    p  = wrf_user_getvar(a,"pressure",it) ; total pressure
    qv_plane = wrf_user_intrp3d(qv,p,"h",pressure,0.,False)
    ;; printVarSummary(qv_plane)

    opts = res
    opts@cnFillOn         = True
    opts@cnFillColor = True
    opts@gsnSpreadColors  = False
    ;; opts@cnLevelSelectionMode = "ExplicitLevels"
    ;; opts@cnLevels =  fspan(261.,280.,40)

    opts@ContourParameters = (/ 0., 3., .1 /)
    opts@PlotLevelID      = "Eta Level  " + pressure

    pltres@NoTitles = True


    if (isvar("qv_plane"))
      contour = wrf_contour(a,wks,qv_plane(:,:),opts)
      plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
      delete(contour)
    end if

  end do

end
