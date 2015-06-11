; http://www.micromet.psu.edu/datatransfer/1999PacificOcean/fnl/plot_fnl_Figure1.ncl

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

function theta_eqv(T:numeric, X:numeric, p0:numeric, p:numeric)
;
; calculate equivalent potential temperature
;
; T : Temperature [K] (time,lev,lat,lon)
; X : mixing ratio of water vapor in air [kg/kg] (time,lev,lat,lon)
; p0 : reference pressure [ usually 1000 mb or 100000 Pa ]
; p ; pressure at each level [must be same units as p0 ]
local T_e, L_v, c_pd, R, Rcpd, dimT, dimX, P
begin
  L_v = 2400. ; latent heat of evaporation [approx 2400 kJ/kg at 25C]
  c_pd = 1004. ; specific heat at constant pressure for air [approx 1004 J/(kg-K)]
  R = 287. ; specific gas constant for air [J/(kg-K)]
  Rcpd = R/c_pd

  dimT = dimsizes(T)
  dimX = dimsizes(X)
  if (dimsizes(dimT) .ne. dimsizes(dimX)) then
    print("theta_eqv: rank of T .ne. rank of X")
    exit
  end if

;   P = conform(T,p,1) ; make p same shape/rank/size as T
  P = p
  T_e = T + (L_v/c_pd)*X ; common approximation
  theta_e = T_e*(p0/P)^Rcpd

;   theta_e@long_name = "equivalent potential temperature"
  theta_e@long_name = "~F8~q~F21~~B~E~N~"
  theta_e@units = "K"
  copy_VarCoords(T, theta_e) ; assign coordinates

  return(theta_e)
end

vars = (/"PRMSL_3_MSL_10"/)

;   gfs_files = systemfunc("ls ./fnl_19990*00")
diri = "/home/yagnesh/DATA/FNL/20081226/"
fnam = "fnl_20081226_12_00_c"
gfs_files = diri + fnam

; grb_file = addfile(diri+fnam+".grb","r")
; gfs_files = systemfunc("ls ./fnl_19990814_12_00")

do ifile = 0 , dimsizes(gfs_files)-1

  f=addfile(gfs_files(ifile)+".grb","r")
  vars_to_check = getfilevarnames(f)
;   list_filevars(f)
  a4_height = 29.7 ; in centimeters, if my
  a4_width = 23.0 ; reference is correct
  cm_per_inch = 2.54

  res                       = True             ; plot mods desired
  res@mpDataBaseVersion  = "Ncarg4_1"
  res@mpDataSetName      = "Earth..4"

  res@gsnFrame  = False
  res@gsnDraw  = False
;  res@gsnMaximize = True
;  res@gsnPaperOrientation   = "portrait"
  res@vpHeightF             =0.29
  res@vpWidthF              = 0.66
  res@vpXF             = 0.11

  res@mpOutlineBoundarySets = "AllBoundaries"
  res@gsnSpreadColors       = True             ; use full range of colormap
  res@cnFillOn              = True             ; color plot desired
  res@cnLinesOn             = False            ; turn off contour lines
  res@cnLineLabelsOn        = False            ; turn off contour labels
;  res@cnFillDrawOrder  = "PostDraw"          ; areas before map gets set
;  res@mpOutlineDrawOrder    = "PostDraw"      ; draw continental outline last
;  res@mpLandFillColor = "Transparent"
;  res@mpGeophysicalLineColor = "black"
;  res@mpGeophysicalLineThicknessF = 1.5          ; thickness of outlines
  res@mpOutlineOn = True

  res@mpOutlineBoundarySets = "GeophysicalAndUSStates" ; state boundaries
  res@tmXTOn = False            ; turn off top   labels
  res@tmYROn = False            ; turn off right labels
  res@cnInfoLabelOn       = False
  res@cnInfoLabelOrthogonalPosF = -0.04
;  res@cnInfoLabelString   = "Min= $ZMN$ Max= $ZMX$"
;  res@gsnAddCyclic       = True

;  res@mpProjection          = "LambertConformal"
;  res@mpProjection          = "CylindricalEquidistant"
;  res@mpLambertParallel1F   = 70.446
;  res@mpLambertParallel2F   = 70.446
;  res@mpLambertMeridianF    = -174.685
  res@mpLimitMode           = "LatLon"

  res@trYReverse = True
  res@vcRefMagnitudeF          = 8.             ; define vector ref mag
  res@vcRefLengthF             = 0.025          ; define length of vec ref
  res@vcRefAnnoOrthogonalPosF  = -1.            ; move ref vector
  res@vcRefAnnoParallelPosF  = 0.99
  res@vcMinDistanceF           = 0.025            ; larger means sparser
  res@vcLineArrowHeadMaxSizeF  = 0.0075          ; default: 0.05 (LineArrow), 0.012 (CurlyVector)
  res@vcGlyphStyle             = "CurlyVector"   ; default: "LineArrow"
  res@gsnScalarContour      = True               ; contours desired
  res@tmXBLabelFontHeightF = 0.018
  res@tmYLLabelFontHeightF = 0.018
  res@lbLabelFontHeightF = 0.018
  res@tiYAxisFontHeightF = 0.018
  gsres               = True
  gsres@gsMarkerIndex = 16          ; circle at first
  gsres@gsMarkerThicknessF = 1
  gsres@gsMarkerSizeF = 0.01
  gsres@gsMarkerColor      = "black"
  tres       =  True
  res@vpYF               =1.
  plot = new(3,graphic)
  figurename = "wrfout_gfsinput_Figure1_2ndTry"
  wks = gsn_open_wks("pdf" ,figurename)           ; ps,pdf,x11,ncgm,eps
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200") ; select color map
  res@lbOrientation = "vertical"

  res@lbLabelAutoStride         =True
  lv_ISBL2=f->lv_ISBL2
  HGT_3_ISBL_10=f->HGT_3_ISBL_10(:,90-9,168)
;  res@tmYLMode = "Explicit"
;  res@tmYLValues     = lv_ISBL2(:24:2)
;  res@tmYLLabels     = HGT_3_ISBL_10(:24:2)
  res@mpLimitMode           = "LatLon"
  res@mpMinLatF = 5
  res@mpMaxLatF = 13
  res@mpMinLonF = 160.
  res@mpMaxLonF = 173.

  u=f->U_GRD_3_ISBL_10(19,:,:)
  v=f->V_GRD_3_ISBL_10(19,:,:)
  var_value=f->HGT_3_ISBL_10(19,:,:)
  res@gsnLeftString    = "" ;var_value@long_name + " at 800mb"
  res@gsnRightString    = "" ;var_value@units

;       res@cnMaxLevelValF        = 2100.
  res@cnLevelSelectionMode  = "ManualLevels"
  res@cnMaxLevelValF        = 2050.
  res@cnMinLevelValF       =  2020.
  res@cnLevelSpacingF   =   3.
  res@lbOrientation = "vertical"

  res@lbTitleOn        =  True                ; turn on title
  res@lbTitleString    = "Height, m"
  res@lbTitlePosition  = "Top"              ; title position
  res@lbTitleFontHeightF= .018                ; make title smaller
  res@lbTitleDirection = "Across"             ; title direction
  res@lbTopMarginF = -0.1
  res@lbTitleOffsetF = -0.02
  res@lbLabelStride         =2
  printVarSummary(u)
  printVarSummary(v)
  printVarSummary(var_value)
  res@tmXBLabelsOn = True
  plot(0)      = gsn_csm_vector_scalar_map(wks,u,v,var_value(:,:),res)
  draw(plot(0))
  gsn_polymarker(wks,plot(0),167.7333,8.716666667,gsres)
  tres@txFontHeightF = 0.015
  gsn_text(wks,plot(0),"Kwajalein",167.7333,8.716666667-0.25,tres)
  tres@txFontHeightF = 0.025
  gsn_text(wks,plot(0),"a", 160.7333,12.5,tres)
  delete(res@mpLimitMode);           = "LatLon"
  delete(res@mpMinLatF); = 5
  delete(res@mpMaxLatF); = 13
  delete(res@mpMinLonF); = 160.
  delete(res@mpMaxLonF); = 173.

  delete(var_value)
  res@tiYAxisString         = "Height, m"
  res@tmYLLabelStride = 2
  res@vpWidthF              = 0.48
  res@vpXF             = 0.2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  var_value=f->TMP_3_ISBL_10(:,::-1,168)

  rh = f->R_H_3_ISBL_10(:,:,:) ; I think level 8 is at 500mb
  printVarSummary(f->R_H_3_ISBL_10)
  tk=f->TMP_3_ISBL_10(5:,:,:)
  p = tk
  do ilevel = 0 , 20
;;      if (ifile.eq.54.or.ifile.eq.55) then
    p(ilevel,:,:) = (/f->lv_ISBL6(ilevel)/)
;      else
;        p(ilevel,:,:) = (/f->lv_ISBL5(ilevel)/)
;      end if
  end do
  q = mixhum_ptrh (p, tk, rh,-2) ; q = 5.9    ( g/kg)
  res@cnMaxLevelValF        = 17.
  res@cnMinLevelValF       =  5.;1000;1940
  res@cnLevelSpacingF   =   1.
  copy_VarCoords(rh, q)
  var_value = q(:,::-1,168)
  printVarSummary(var_value)
  var_value!0 = "Height"
  res@trYReverse = False
  printVarSummary(var_value)
  var_value&Height = floattoint (HGT_3_ISBL_10(5:))
  res@trYReverse = False

  res@gsnLeftString    = "Specific Humidity, g/kg"
  res@gsnLeftString    = "";var_value@long_name + ","+var_value@units
  res@gsnRightString    =""; var_value@long_name + ","+var_value@units

  res@lbTitleOn        =  True                ; turn on title
  res@lbTitleString    = "q, g kg~S~-1"
  res@lbTitlePosition  = "Top"              ; title position
  res@lbTitleFontHeightF= .018                ; make title smaller
  res@lbTitleDirection = "Across"             ; title direction
  res@lbTopMarginF = -0.1
  res@lbTitleOffsetF = -0.02
  res@trXMinF           =  5
  res@trXMaxF           =  13
  res@trYMaxF           =  3000
  res@vpYF              =0.35
  res@tmXBLabelsOn = True
  plot(2)      = gsn_csm_contour(wks,var_value(:,:),res)
  draw(plot(2))
  gsn_polymarker(wks,plot(2),8.716666667,100,gsres)
  tres@txFontHeightF = 0.015
  gsn_text(wks,plot(2),"Kwajalein",8.716666667,100.+100.,tres)
  tres@txFontHeightF = 0.025
  gsn_text(wks,plot(2),"c",5.5,2600,tres)
  delete(var_value)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  res@tmXBLabelFontHeightF = 0.018
  res@tmYLLabelFontHeightF = 0.018
  res@lbLabelFontHeightF = 0.018

  X = q/1000
  X = X/(1-X) ; convert spc humidity to mixing ratio
  X@long_name = "mixing ratio"
  p0=X
  p0 = (/1000/)
  p0@units = "hPa" ; must match units of p
  p@units = "hPa" ; must match units of p
  THETAE = theta_eqv(tk, X, p0, p)
  var_value = THETAE(:,::-1,168)
  var_value!0 = "Height"
;   printVarSummary(var_value)
  var_value&Height = floattoint (HGT_3_ISBL_10(5:))
;    printVarSummary(var_value)
  res@cnMaxLevelValF        = 312.
  res@cnMinLevelValF       =  300.;1000;1940
  res@cnLevelSpacingF   =   1.5
  res@lbTitleOffsetF = -0.02
  res@lbTopMarginF = -0.1

  res@gsnLeftString    = "";var_value@long_name + ","+var_value@units
  res@gsnRightString    =""; var_value@long_name + ","+var_value@units
  res@lbTitleString    = "   "+var_value@long_name + ","+var_value@units
  res@vpYF              =0.65
  res@tmXBLabelsOn = False
  plot(1)      = gsn_csm_contour(wks,var_value(:,:),res)
  draw(plot(1))
  gsn_polymarker(wks,plot(1),8.716666667,100,gsres)
  tres@txFontHeightF = 0.015
  gsn_text(wks,plot(1),"Kwajalein",8.716666667,100.+100.,tres)
  tres@txFontHeightF = 0.025
  gsn_text(wks,plot(1),"b",5.5,2600,tres)

  frame(wks)
  system("convert -trim "+figurename+".eps /micromet/s1/www/htdocs/datatransfer/1999PacificOcean/fnl/"+figurename+".png")
  system("mv "+figurename+".pdf /micromet/s1/www/htdocs/datatransfer/1999PacificOcean/fnl/"+figurename+".pdf")
  print("finish plotting "+figurename+".pdf")

  delete(vars_to_check)
end do ; do ifile
