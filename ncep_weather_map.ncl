; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
; Created: Wednesday, February 19 2014
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
load "$nsc/yagUtils.ncl"

begin
  f = addfile("fnl_20081226_12_00_c.grib","r")

  p = f->PRMSL_3_MSL
  t = f->TMP_3_SFC

  wks_type          = "pdf"
  wks = gsn_open_wks(wks_type,"weather")

  res= True
  res@mpMinLonF                     = 122.5
  res@mpMaxLonF                     = 155.5
  res@mpMinLatF                     = 27.5
  res@mpMaxLatF                     =  62.5


  res = set_res_cn(res)
  set_res_cn_limits(res,250,300,2)

  opts = True
  set_res_cn_limits(opts,980,1010,2)
  opts@mpMinLonF                     = 122.5
  opts@mpMaxLonF                     = 155.5
  opts@mpMinLatF                     = 27.5
  opts@mpMaxLatF                     =  62.5

  ; plot = gsn_csm_contour_map_overlay(wks,t,p/100,res,opts)

  ; map = gsn_csm_contour_map(wks,t,res)
  p = gsn_csm_contour_map(wks,p/100,opts)

  ; overlay(map,tit)
end
