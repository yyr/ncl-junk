;;    File: div.ncl
;;  Author: Yagnesh Raghava Yakkala <hi@yagnesh.org>
;; Created: Tuesday, September 20 2011
;; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;;

load "$nsc/yagUtils.ncl"

begin

  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

  u = wrf_user_getvar(a,"U10",95)
  v = wrf_user_getvar(a,"V10",95)
  msft = wrf_user_getvar(a,"MAPFAC_M",1)

  dx        = a@DX
  dy        = a@DY

  dim = dimsizes(u)
  div = new( (/ dim(0), dim(1) /) , typeof(u))

  div = wrf_div(u,v,dx,dy,msft)

  wks = gsn_open_wks("X11","temp")
;  gsn_define_colormap(wks,"hotcold_18lev")            ; choose color map

  res = True
  res@Footer = False
  res@gsnSpreadColors = True    ;spread Colors

  opts = res
  opts = set_no_frame_res(opts)
  opts = set_cn_resorces(opts)
  opts@ContourParameters = (/-.02,.02,.002/)

  cn  = wrf_contour(a,wks,div,opts)
  plot = wrf_map_overlays(a,wks,(/cn/),True,True)

end
