load "$nsc/yagUtils.ncl"

begin

  type = "png"
  wks = gsn_open_wks(type,"domain")

  filename = "$nsc/namelist.wps"
  a = addfile("./wrfout_d01_2008-12-25_00:00:00.nc","r")

  opts = True
  hgt = hgt_contour(a,wks,opts)
  draw(hgt)

; Set some map information ; line and text information
  mpres = True
  mpres@mpFillOn = False
;  mpres@mpFillColors  = (/"background","DeepSkyBlue","ForestGreen","DeepSkyBlue", "transparent"/)
  mpres@mpGeophysicalLineColor      = "Black"
  mpres@mpGridLineColor             = "Black"
  mpres@mpLimbLineColor             = "Black"
  mpres@mpDataBaseVersion    = "HighRes"
  mpres@mpGeophysicalLineThicknessF = 2.0

  lnres = True
  lnres@gsLineThicknessF = 2.5
  lnres@gsLineColor = "Red"

  txres = True
  txres@txFont = "helvetica-bold"
  txres@txJust = "BottomLeft"
  txres@txPerimOn = False
  txres@txFontHeightF = 0.015

  mpres = wps_parse_namelist_for_domain(filename,mpres)
  mp = wrf_wps_dom(wks,hgt,mpres,lnres,txres)

  frame(wks)
end
