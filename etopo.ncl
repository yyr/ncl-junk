;; topography map from etopo data.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

  din = "~/DATA/terrain/"
  dout = "~/fig/"

    fin = "ETOPO1_Ice_g_gmt4.grd"

  ;; latitude values
    sl = 30.
    nl = 60.

  ;; longitude values
    wl = 130.
    el = 160.

;;--------------------------------------------------------------------
    f = addfile(din + fin + ".nc","r")
    z = f->z

    wks = gsn_open_wks("png","topo")
  gsn_define_colormap(wks,"gsdtol")   ; overwrite the .hluresfile color map
;  gsn_define_colormap(wks,"BlueRedGray")   ; overwrite the .hluresfile color map

  ;; convertion
    s = (sl+90)*60
    n = (nl+90)*60

    w = (wl+180)*60
    e = (el+180)*60

  ;; printVarSummary(z)
  ;; print("s" + s + "n" + n + "w" + w + "e" + e)

    z&x@units = "degrees_east"
    z&y@units = "degrees_north"


    res = True ; options desired
    res@gsnMaximize = True ; maximize size of plot
    res@gsnLeftString = "Height in meters"
    res@tiMainString = "Topographical Map of East Asian region"

    res@cnFillOn = True
    res@gsnSpreadColors=True
    res@cnLinesOn = False
    res@cnLineLabelsOn = False

    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF = 0.
    res@cnMaxLevelValF = 4000.
    res@cnLevelSpacingF = 200.

  ;; lablebar
    res@lbOrientation = "vertical"
    res@lbLabelStride = 2

    ;; res@lbLabelStrings =  (/0., 100., 200., 400., 800., 1600., 3200., 4000. /)

    mpres  = True  ; Map resources
    mpres@mpDataBaseVersion    = "HighRes"
    mpres@mpGeophysicalLineThicknessF = 2.0
    mpres@mpGeophysicalLineColor = "Black"
    mpres@mpLimitMode = "LatLon"
    mpres@mpMinLatF = sl
    mpres@mpMaxLatF = nl
    mpres@mpMinLonF = wl
    mpres@mpMaxLonF = el

    plot = gsn_csm_contour_map(wks,z,mpres)

  end
