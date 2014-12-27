;    File: panel_t.ncl
; Created: Friday, September  9 2011
; License: GPL v3 or later.
;

; Description:
;

import("yag_utils")

begin
  a = set_inputfile()

  type = "ps"
  out = "snownc"       ;out put file name
  tvalues = (/ 0,47,90,92,94,96 /)   ;specify desired timestep outputs must be even

  wks = gsn_open_wks(type,out)

  res = True
  res@gsnSpreadColors = True    ;spread Colors
  res@lbLabelBarOn        = False           ; turn off individual cb's

  pltres = True ; Plot resources
  mpres = set_res_highres_coast(True)

  times  = wrf_user_list_times(a)  ; get times in the file
  noft = dimsizes(tvalues)
  plot = new(noft,graphic)

  do it = 0, noft - 1, 1   ;; LOOP NAME
    print("tvalue: " + tvalues(it))

    print("Working on time: " + times(tvalues(it)))
    res@TimeLabel = times(tvalues(it))   ; Set Valid time to use on plots

    if(isfilevar(a,"SNOWNC"))
      snownc = wrf_user_getvar(a,"SNOWNC",tvalues(it))
    end if

    res = set_res_no_frame(res)
    res@cnInfoLabelOn = False        ; turn off contour info label

    opts = res
    opts@cnFillOn         = True
    opts@cnFillColor = True
    opts@InitTime = False
    level =5

    mpres@gsnMaximize = True

    if (isvar("snownc"))
      contour = wrf_contour(a,wks,snownc(:,:),opts)
      plot(it) = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
      delete(contour)
    end if

  end do

  pres                = True            ; mod panel plot
  pres@lbLabelStride  =  1              ; skip every other label
  pres@txString         = "Accumilated Snow Fall mm"     ; add common title
  panelize_2col(wks,plot,pres)
end
