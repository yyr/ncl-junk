;************************************
; unique_4.ncl
;
; Concepts illustrated:
;   - Overlaying vectors, streamlines, filled contours on a map
;   - Creating animations
;   - Drawing both a vertical and horizontal labelbar
;************************************
;
; This example does an animation of the January 1996 snow storm.
; Wind vectors colored by temperature are animated over a pressure
; field contour plot, with streamlines at 500 mb overlaid.
;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"


begin
;
; Open some netCDF files.
;
  dir   = ncargpath("data") + "/cdf/"
  uf    = addfile(dir + "Ustorm.cdf","r")
  vf    = addfile(dir + "Vstorm.cdf","r")
  pf    = addfile(dir + "Pstorm.cdf","r")
  tf    = addfile(dir + "Tstorm.cdf","r")
  u500f = addfile(dir + "U500storm.cdf","r")
  v500f = addfile(dir + "V500storm.cdf","r")

;
; Read variables off the file and do some conversions.
;
  p    = pf->p/100.0
  t    = (tf->t - 273.15) * 9.0/5.0 +32.0
  u    = uf->u
  v    = vf->v
  u500 = u500f->u
  v500 = v500f->v

;
; Title information for later.
;
  time = vf->timestep

  title = "January 1996 Snow Storm~C~    " + vf->reftime + " + " + time(0)

  anno_title = "Contours represent pressure field.~C~" + \
               "Vectors represent wind direction~C~" + \
               "colored by temperature.~C~" + \
               "Black streamlines represent 500 mb winds."

;
; Open a workstation and define a rainbow colormap w/a black background.
;
  type                   = "ps"
  type@wkColorMap        = "temp1"
  type@wkBackgroundColor = "black"
  type@wkForegroundColor = "white"
  wks                    = gsn_open_wks(type,"unique")

;
; Set up some variables to hold various resource lists.  Turn
; off draw and frame for all plots, because we are going to do
; some overlays later and then we'll draw everything.
;
  vcres           = True
  vcres@gsnDraw   = False
  vcres@gsnFrame  = False
  stres           = vcres
  cnres           = vcres
  mpres           = vcres

;
; Set up some vector resources.
;
; Vector and scalar field resources.
;
  vcres@vfXCStartV   = uf->lon(0)
  vcres@vfXCEndV     = uf->lon(filevardimsizes(uf,"lon")-1)
  vcres@vfYCStartV   = uf->lat(0)
  vcres@vfYCEndV     = uf->lat(filevardimsizes(uf,"lat")-1)
  vcres@vfXCStride   = 2
  vcres@vfYCStride   = 2

  vcres@sfXCStartV   = tf->lon(0)
  vcres@sfXCEndV     = tf->lon(filevardimsizes(tf,"lon")-1)
  vcres@sfYCStartV   = tf->lat(0)
  vcres@sfYCEndV     = tf->lat(filevardimsizes(tf,"lat")-1)
  vcres@sfXCStride   = 2
  vcres@sfYCStride   = 2

;
; Labelbar resources
;
  vcres@lbOrientation         = "Vertical"
  vcres@lbPerimOn             = False
  vcres@pmLabelBarDisplayMode = "Always"
  vcres@pmLabelBarWidthF      = 0.1
  vcres@lbTitleOn             = True
  vcres@lbTitleFont           = "Helvetica"
  vcres@lbLabelFont           = "Helvetica"
  vcres@lbTitleString         = "Surface Temperature"
  vcres@lbTitlePosition       = "Left"
  vcres@lbTitleOffsetF        = 0.13
;
; Vector levels and colors
;
  vcres@vcLevelSelectionMode     = "ManualLevels"
  vcres@vcMinLevelValF           = -20.0
  vcres@vcMaxLevelValF           =  100.0
  vcres@vcLevelSpacingF          = 20.0
  vcres@vcLevelColors            = (/4,12,20,28,36,44,52,60/)

;
; Vector lengths and color
;
  vcres@vcFillArrowsOn           = True
  vcres@vcLineArrowThicknessF    =  2.0

  vcres@vcMinFracLengthF         = 0.33
  vcres@vcMinFracLengthF         = 0.33
  vcres@vcMinMagnitudeF          = 0.001
  vcres@vcMonoFillArrowFillColor = False
  vcres@vcMonoLineArrowColor     = False

  vcres@vcUseRefAnnoRes          = True
  vcres@vcRefLengthF             = 0.045
  vcres@vcRefMagnitudeF          = 20.0

;
; Annotation info for vectors.
;
  vcres@vcRefAnnoZone            = 4
  vcres@vcRefAnnoFont            = "Helvetica-Bold"
  vcres@vcRefAnnoFontColor       = "Black"
  vcres@vcRefAnnoString1         = "$VMG$ meters per second"
  vcres@vcRefAnnoString2On       = False
  vcres@vcRefAnnoBackgroundColor = "LightGray"
  vcres@vcRefAnnoPerimOn         = False

  vcres@vcMinAnnoZone               = 4
  vcres@vcMinAnnoOn                 = True
  vcres@vcMinAnnoFont               = "Helvetica-Bold"
  vcres@vcMinAnnoFontColor          = "Green"
  vcres@vcMinAnnoExplicitMagnitudeF = 5.0
  vcres@vcMinAnnoString1            = "$VMG$ meters per second"
  vcres@vcMinAnnoString2On          = False
  vcres@vcMinAnnoParallelPosF       = 0.75

;
; Make sure vectors are drawn in "predraw" phase.
;
  vcres@vcVectorDrawOrder        = "Predraw"

;
; Create, but don't draw, a vector plot.
;
  vcid = gsn_vector_scalar(wks,u(0,:,:),v(0,:,:),t(0,:,:),vcres)

;
; Set up some streamline resources.
;
; Vector field resources.
;
  stres@vfXCStartV   = u500f->lon(0)
  stres@vfXCEndV     = u500f->lon(filevardimsizes(u500f,"lon")-1)
  stres@vfYCStartV   = u500f->lat(0)
  stres@vfYCEndV     = u500f->lat(filevardimsizes(u500f,"lat")-1)

  stres@stLineColor  = "Black"

;
; Create, but don't draw, a streamline plot.
;
  stid = gsn_streamline(wks,u500(0,:,:),v500(0,:,:),stres)

;
; Set up some contour resources.
;
; Scalar field resources
;
  cnres@sfXCStartV            = pf->lon(0)
  cnres@sfYCStartV            = pf->lat(0)
  cnres@sfXCEndV              = pf->lon(filevardimsizes(pf,"lon")-1)
  cnres@sfYCEndV              = pf->lat(filevardimsizes(pf,"lat")-1)
  cnres@sfXCStride            = 2
  cnres@sfYCStride            = 2

;
; Turn on contour fill, and turn other things off.
;
  cnres@cnFillOn             = True
  cnres@cnLinesOn            = False
  cnres@cnLineLabelsOn       = False
  cnres@cnHighLabelsOn       = False
  cnres@cnLowLabelsOn        = False
  cnres@cnInfoLabelOn        = False

;
; Define contour levels and their colors.
;
  cnres@cnLevelSelectionMode = "ManualLevels"
  cnres@cnMinLevelValF       = 980.0
  cnres@cnMaxLevelValF       = 1040.0
  cnres@cnLevelSpacingF      = 5.0
  cnres@cnFillColors         = (/4,5,8,11,14,17,20,23,26,29,35,38,41,42/)

;
; Make sure contours are drawn in "predraw" phase.
;
  cnres@cnFillDrawOrder      = "Predraw"

;
; Labelbar resources
;
  cnres@pmLabelBarDisplayMode = "Always"
  cnres@pmLabelBarHeightF     = 0.075
  cnres@pmLabelBarWidthF      = 0.6
  cnres@pmLabelBarSide        = "Top"
  cnres@pmLabelBarZone        = 2
  cnres@lbLabelFont           = "Helvetica"
  cnres@lbOrientation         = "Horizontal"
  cnres@lbPerimOn             = False
  cnres@lbTitleString         = "Sea Level Pressure"
  cnres@lbTitleExtentF        = 0.25
  cnres@lbTitleFontHeightF    = 0.007
  cnres@lbTitleFont           = "Helvetica"
;
; Create, but don't draw, a contour plot.
;
  cnid = gsn_contour(wks,p(0,:,:),cnres)

;
; Set up some map resources.
;
; Define size of map.
;
  mpres@vpXF          = 0.03
  mpres@vpYF          = 0.85
  mpres@vpWidthF      = 0.8
  mpres@vpHeightF     = 0.8
  mpres@vpUseSegments = True

;
; Control appearance of map.
;
  mpres@mpProjection           = "LambertEqualArea"
  mpres@mpLabelsOn             = False
  mpres@mpPerimOn              = False
  mpres@mpGridAndLimbOn        = False
  mpres@mpFillOn               = True
  mpres@mpOutlineDrawOrder     = "Draw"
  mpres@mpFillDrawOrder        = "Predraw"
  mpres@mpOceanFillColor       = 9
  mpres@mpLandFillColor        = 2
;
; Zoom in on area that is roughly the United States.
;
  mpres@mpLimitMode            = "LatLon"
  mpres@mpMinLatF              =   18.
  mpres@mpMaxLatF              =   65.
  mpres@mpMinLonF              = -128.
  mpres@mpMaxLonF              =  -58.
  mpres@mpCenterLonF           = -100.0
  mpres@mpCenterLatF           = 40.0

  mpres@mpGridAndLimbDrawOrder = "Predraw"

;
; Main title
;
  mpres@tiMainString           = title
  mpres@tiMainFont             = "times-roman"
  mpres@tiMainFuncCode         = "~"
  mpres@pmTitleZone            = 3
;
; Create, but don't draw, a map plot.
;
  mpid = gsn_map(wks,"CylindricalEquidistant",mpres)

;
; Set some text resources.
;
  txres               = True
  txres@gsnDraw       = False
  txres@gsnFrame      = False
  txres@txFont        = "Helvetica"
  txres@txFuncCode    = "~"
  txres@txFontHeightF = 0.015
  txid = gsn_create_text_ndc(wks,anno_title,0.25,0.08,txres)

;
; Attach text to the map, so that if we resize the map, the text
; string will be resized accordingly.
;
; The default is that the text will be on the bottom outside of
; the plot. If you want to change this, set amSide to one of "Top"
; "Right", or "Left".
;
  annoid = NhlAddAnnotation(mpid,txid)

  setvalues annoid
    "amZone"           : 4
    "amJust"           : "CenterLeft"  ; Text is flush left.
    "amParallelPosF"   : 0.0           ; Left justify the text wrt plot.
    "amOrthogonalPosF" : 0.02          ; Move text slightly away from plot.
    "amResizeNotify"   : True
  end setvalues

;
; Overlay contour, streamline, and vector plots on the map plot.
;
  overlay(mpid,cnid)
  overlay(mpid,stid)
  overlay(mpid,vcid)

;
; Now that we have all our resources and plot objects set up,
; loop through all or part of the timesteps, grab the data for that
; timestep, and produce a new plot. If you go through all timesteps,
; you will have an animation of about 60 frames.
;
  do i = 0,dimsizes(time)-1,22
    title = vf->reftime + " + " + time(i)
;
; If any of the fields are all missing, skip this timestep.
;
    if(all(ismissing(u(i,:,:))).or.all(ismissing(v(i,:,:))).or. \
       all(ismissing(u500(i,:,:))).or.all(ismissing(v500(i,:,:))).or. \
       all(ismissing(t(i,:,:))).or.all(ismissing(p(i,:,:)))) then
      print("Skipping timestep = " + time(i) + " because one or more fields")
      print("     contain all missing data")
    else
;
; Update the wind, temperature, and pressure data for this timestep.
;
      setvalues vcid@vfdata
        "vfUDataArray" : u(i,:,:)
        "vfVDataArray" : v(i,:,:)
      end setvalues

      setvalues vcid@sfdata
        "sfDataArray" : t(i,:,:)
      end setvalues

      setvalues stid@data
        "vfUDataArray" : u500(i,:,:)
        "vfVDataArray" : v500(i,:,:)
      end setvalues

      setvalues cnid@data
        "sfDataArray" : p(i,:,:)
      end setvalues

      setvalues mpid
        "tiMainString" : title
      end setvalues
;
; Draw the new plots and advance the frame.
;
      draw(mpid)
      frame(wks)

    end if
  end do

end
