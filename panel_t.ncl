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
                                ; type = "x11"
  type = "ps"
  wks = gsn_open_wks(type,"panel_t")
  gsn_define_colormap(wks,"WhBlGrYeRe")   ; overwrite the .hluresfile color map

  res = True
  res@MainTitle = "Surface TEMP"
  res@Footer = False
                                ; res@gsnSpreadColors = True    ;spread Colors

  mpres  = True  ; Map resources
  pltres = True ; Plot resources
  mpres@mpGeophysicalLineThicknessF = 2.0

  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

  do it = 56, 96, 10   ;; LOOP NAME

    if(isfilevar(a,"TSK"))
      tsk = wrf_user_getvar(a,"TSK",it)
    end if

    opts = res
    opts@cnFillOn         = True
    opts@cnLevelSelectionMode = "ExplicitLevels"
    opts@cnLevels =  fspan(261.,280.,40)
    opts@cnFillColor = True

    pltres@NoTitles = True
                                ; pltres@CommonTitle = ""
                                ; pltres@

    contour = wrf_contour(a,wks,tsk,opts)
    plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
    delete(contour)

  end do


end
