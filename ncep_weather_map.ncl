; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
; Created: Wednesday, February 19 2014
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
import("yag_utils")

begin
  diri = "/home/yagnesh/DATA/FNL/weak08_1/"
  fnam = "fnl_20080118_18_00"
  f  = addfile(diri+fnam+".grb","r")


  p = f->PRMSL_3_MSL
;  t = f->TMP_3_SFC
  u = f->U_GRD_3_ISBL
  v = f->V_GRD_3_ISBL

  ; lat =

  ; lat@long_name = "Latitude"
  ; lat@standard_name = "latitude"
  ; lat@units = "degrees_north"
  ; lat!0 = "south_north"
  ; lat!1 = "west_east"

  ; lon = (/wrfout->XLONG(0,:,:)/)       ;lon (mass)
  ; lon@long_name = "Longitude"
  ; lon@standard_name = "longitude"
  ; lon@units = "degrees_east"
  ; lon!0 = "south_north"
  ; lon!1 = "west_east"


  wks_type          = "pdf"
  wks = gsn_open_wks(wks_type,"ncep_wind")

  res_com= True
  res_com@mpMinLonF                     = 122.5
  res_com@mpMaxLonF                     = 155.5
  res_com@mpMinLatF                     = 27.5
  res_com@mpMaxLatF                     =  62.5
  w_opts = res_com

  res_com = set_res_highres_coast(res_com)
  res_com = set_res_cn(res_com)
  res_com@mpOutlineOn = True

  res = res_com
  set_res_cn_limits(res,250,300,2)

  opts = res_com
  set_res_cn_limits(opts,970,1020,2)

  opts@cnFillOn =False
  opts@cnLineLabelsOn = True

  w_opts = set_res_vc(w_opts)
  printVarSummary(u)

  wmap = gsn_csm_vector_map(wks,u(25,:,:),v(25,:,:),w_opts)

  ; plot = gsn_csm_contour_map_overlay(wks,t,p/100,res,opts)
  ; map = gsn_csm_contour_map(wks,t,res)
;  pmap = gsn_csm_contour_map(wks,p/100,opts)

  ; overlay(map,pmap)

end
