load "$nsc/yagUtils.ncl"

begin
  f1 = addfile("uwnd.2008.nc","r")
  f2 = addfile("vwnd.2008.nc","r")

  u = short2flt(f1->uwnd(:,{1000},:,:))
  v = short2flt(f2->vwnd(:,{1000},:,:))

  speed = sqrt(u^2+v^2)

  months = (/"Jan"    , "Feb" , "Mar"    , "Apr" \
  ,"May"     , "Jun"     , "Jul"    , "Aug"\
  ,"Sep" , "Oct"   , "Nov" , "Dec"/)

  tClmu = calculate_monthly_values( u,"avg",0,False )
  tClmv = calculate_monthly_values( v, "avg",0,False )

;  tClmu = clmMonTLL( u )
;  tClmv = clmMonTLL( v )


  do mon = 0,11

;  mon = 11

    filename = "VEL_1000"+months(mon)

    wks_type          = "ps"
;    wks_type@wkWidth  = 600
;    wks_type@wkHeight = 800
    wks = gsn_open_wks(wks_type,filename)

;    gsn_define_colormap(wks,"gui_d")

    print ("Mon --> " + months(mon))

    res                      = True          ; Plot options set

    res@gsnAddCyclic         = True          ; Add a longitude cyclic point.
    res@vcMonoLineArrowColor = False         ; Turn on color vectors
    res@gsnSpreadColors      = True          ; Span the color map
    res@gsnSpreadColorEnd    = -2            ; Don't include gray at end
    res@vcRefMagnitudeF      = 15           ; Define reference magnitude
    res@vcRefLengthF         = 0.07         ; Define length of vector reference
    res@vcRefAnnoOrthogonalPosF   = -1    ; Move reference into plot.
    res@vcRefAnnoArrowUseVecColor = False    ; Allow us to change ref vec color
    res@vcRefAnnoArrowLineColor   = "black"  ; Black ref vector

    res@tiMainString                  = "2008 monthly mean velocity filed"
    res@gsnLeftString                 = "NCEP-2"
    res@gsnRightString                = "m/s"
    res@gsnCenterString               = months(mon)

    res@mpMinLonF                     = 122.5
    res@mpMaxLonF                     = 155.5
    res@mpMinLatF                     = 27.5
    res@mpMaxLatF                     =  62.5

    res@mpOutlineBoundarySets         = "National"
    res@gsnMaximize                   = True
    res@gsnMajorLonSpacing            = 10
    res@gsnMajorLatSpacing            = 10
    res@mpDataSetName                 = "Earth..4"
    res@mpDataBaseVersion             = "MediumRes"
    res@mpOutlineOn                   = True
;    res@mpOutlineSpecifiers           = (/"Japan"/)
    res@pmLabelBarDisplayMode    = "Always"

;
; Instead of thinning the vectors by subscripting the data with "::4",
; you can instead thin the vectors with the resource below.
;
    res@vcMinDistanceF       = 0.005         ; Thin the vectors

;  res@mpFillDrawOrder      = "Postdraw"    ; Draw filled map last
;plot = gsn_csm_vector_map(wks,u,v,res)   ; Call the gsn_csm function for

    plot = gsn_csm_vector_map(wks,tClmu(mon,:,:),tClmv(mon,:,:),res)

  end do
                                ; drawing the vectors over a map.
end
