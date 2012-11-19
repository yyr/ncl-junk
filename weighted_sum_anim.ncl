;    File: weighted_sum.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Wednesday, October 12 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
; weithted sum: from Hydrostatic equation
; dP/dz = - ro * g (ro = density )

load "$nsc/yagUtils.ncl"

begin

 a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")
  type = "ps"

  varname = "QSNOW"

  out = "wgt_sum_" + varname       ;out put file name

  wks = gsn_open_wks(type,out)

  noflevels = 32                ; how many layers should be added


  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

  do it = 44, 144, 1   ;; LOOP NAME

    vt = it
    print("working with: " + times(vt))

    wgted_var = wrf_user_getvar_weighted_sum(a,varname,vt)

    wgted_var = wgted_var * 1000. ;
    wgted_var@units = "g"

    res = True
    res@gsnSpreadColors = True    ;spread Colors
    res@TimeLabel = times(vt)   ; Set Valid time to use on plots
    res@Footer = False

    opts = res
    opts@cnFillOn         = True
    opts@cnFillColor = True
    if ( varname .eq. "QSNOW"  ) then
      opts@ContourParameters = (/ 0., 2.6, .02 /)
    end if
    if ( varname .eq. "QICE"  ) then
      opts@ContourParameters = (/ 0., 0.01, .001 /)
    end if

    ;  opts@lbLabelBarOn        = False           ; turn off individual cb's
    opts@InitTime = False

    mpres  = True  ; Map resources
    pltres = True ; Plot resources

    contour = wrf_contour(a,wks,wgted_var,opts)
    plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)

  end do


end
