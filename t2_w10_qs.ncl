; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: t2_w10_qs.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Monday, November 14 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
;

load "$nsc/yagUtils.ncl"

begin
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

 type = "ps"
  ;; type = "png"
  out = "qs_over"
  wks = gsn_open_wks(type,out)
  gsn_define_colormap(wks,"temp_19lev")   ; overwrite the .hluresfile color map
;  gsn_reverse_colormap(wks)

  varname = "QSNOW"
  noflevels = 32                ; how many layers should be added

  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

;--------------------------------------------------------------------

  do it = 48, 95, 1   ;; LOOP NAME
    vt = it
;     vt = it + 96
;  notify time
    print("working with: " + times(vt))


;;--------------------------------------------------------------------
;;-- qsnow  --
    wgted_var = wrf_user_getvar_weighted_sum(a,varname,vt)
    wgted_var = wgted_var * 1000. ;
    wgted_var@units = "g"

    res = True
    res@TimeLabel = times(vt)   ; Set Valid time to use on plots
    res@Footer = False
;    res@gsnDraw              = False              ; Do not draw plot
;    res@gsnFrame             = False              ; Do not advance frame

    opts = res
    opts@ContourParameters = (/ 0., 2.6, .2 /)
    opts@InitTime = False
    contour = wrf_contour(a,wks,wgted_var,opts)
    delete(opts)


;;--------------------------------------------------------------------
;;-- t2  --

    optsT = res
    optsT@cnFillOn         = True
    optsT@cnFillColor = True
    optsT@ContourParameters = (/ 260.,280., 0.5 /)
    optsT@InitTime = False
    ;; optsT@ValidTime = False

    optsT@cnInfoLabelOn = False        ; turn off contour info label
    t2 = wrf_user_getvar(a,"T2",vt)
    contour_t = wrf_contour(a,wks,t2,optsT)
    delete(optsT)


;;--------------------------------------------------------------------
;;-- wind10  --

    u10 = wrf_user_getvar(a,"U10",vt)   ; U component of the wind at 10m
    v10 = wrf_user_getvar(a,"V10",vt)   ; V component of the wind at 10m

    optsW = res
    optsW@FieldTitle = "Wind"       ; overwrite Field Title
    optsW@InitTime = False
    optsW@vcGlyphStyle = "LineArrow"
    optsW@vcGlyphStyle        = "CurlyVector"    ; turn on curly vectors


    vector = wrf_vector(a,wks,u10,v10,optsW)
    delete(optsW)

;;--------------------------------------------------------------------
;;-- plot/overlay all  --
    pltres = True ; Plot resources
    pltres@NoTitles = True
    pltres@MainTitlePos= False

    mpres  = True  ; Map resources
    mpres@mpDataBaseVersion    = "HighRes"
    mpres@mpGeophysicalLineThicknessF = 2.0


;    plot = wrf_map_overlays(a,wks,(/contour,contour_t/),pltres,mpres)
    plot = wrf_map_overlays(a,wks,(/vector,contour_t,contour/),pltres,mpres)
    delete(pltres)
    delete(mpres)

  end do

end
;;; t2_w10_qs.ncl ends here
