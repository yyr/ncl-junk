import("yagUtils")

begin
  a = set_inputfile()
  coard = (/265,336,126,223/)
  wks = gsn_open_wks("ps","barb")
  gsn_define_colormap(wks,"WhBlGrYeRe")

  u = a->U          ; (time, lev)
  u_a = u(:,:,265:336,126:223)
  delete(u)
  u_area = dim_avg_n_Wrap(u_a,(/2,3/))
  delete(u_a)

  v = a->V           ; (time, lev)
  v_a = v(:,:,265:336,126:223)
  delete(v)
  v_area = dim_avg_n_Wrap(v_a,(/2,3/))
  delete(v_a)

  wspd = (/ sqrt(u_area^2+v_area^2) /)
  wspd!0 = "Time"
  wspd!1 = "lev"

  times = a->Times
  tlen = dim_len0(times) - 1

  qs = a->QSNOW           ; (time, lev)
  qs_a = qs(:,:,265:336,126:223)
  delete(qs)
  qs_mean = dim_avg_n_Wrap(qs_a,(/2,3/))
  delete(qs_a)

  qs_mean!0 = "Time"
  qs_mean!1 = "lev"
  qs_mean = qs_mean * 1000
  qs_mean@units = "g kg-1"


  res                = True
  res = set_res_no_frame(res)


  res@tiMainString   = "Snow vs Wind"
  res@vcGlyphStyle   = "WindBarb"
  res@vcRefLengthF   = 0.03

  res@vcRefAnnoOn    = False

  res@vcMonoWindBarbColor     = True
  res@vcWindBarbLineThicknessF= 1.5              ; set the wind barb thickness
  res@vcLevels                = ispan(5,50,5)    ; set the levels

  ; res@lbOrientation           = "vertical"
  ; res@vcLevelSelectionMode    = "ExplicitLevels"
  ; res@vcLevelColors           = (/20,30,40,45,50,55,60,65,70,75,80,85,90,95/)   ; set the colors associated with the wind speed

  res@vcMapDirection = False            ; needed to disassociate the map from the vectors
  res@gsnLeftString = ""

  plot = gsn_csm_vector_scalar(wks,\
                               u_area(bottom_top|:15,Time|0:tlen:4),\
                               v_area(bottom_top|:15,Time|0:tlen:4),\
                               wspd(lev|:15,Time|0:tlen:4),\
                               res)

  resc = True
  resc = set_res_no_frame(resc)
  resc@cnFillOn =True
  plot_c = gsn_csm_contour(wks,qs_mean(lev|:15,Time|0:tlen:4),resc)
  overlay(plot_c,plot)

  draw(wks)
  frame(wks)

end
