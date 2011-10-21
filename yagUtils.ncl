; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: utils.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Wednesday, September 21 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
; my dumb functions
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;;--------------------------------------------------------------------
undef("yag_draw_2d")
function yag_draw_2d(var:numeric)
begin


end

undef("no_of_levels")
function yag_draw_2d(f:file)
begin
  dims = dimsizes(var)

end

;;--------------------------------------------------------------------
; weighted_sum to weight of the layer will be calculated using
; hydrostatic equation.

undef("wrf_user_getvar_weighted_sum")
function wrf_user_getvar_weighted_sum(file_handle,var_in:string,time_in:integer)
local var,varname, var, ph,phb,pres,gh,dim, wgt_var, noflevels, \
lay_var,dgh,dp, lay_wgt, lay_wgt_var, wgt_var,time,g

begin
  g = 9.8                       ; gravity

; check the file handle is okay
  if(typeof(file_handle).eq."file") then
    ISFILE = True
    nc_file = file_handle
  else
    print("wrf_user_getvar: error: the first argument must be a file or a list of files opened with addfile or addfiles")
    return
  end if

; get var we need to return
  varname=var_in(0)
  time = time_in(0)

  var = wrf_user_getvar(nc_file,varname,time)
  ph = wrf_user_getvar(nc_file,"PH",time)
  phb = wrf_user_getvar(nc_file,"PHB",time)
  pres = wrf_user_getvar(nc_file,"pressure",time)
  gh = ph + phb               ;geo potential height
;  print(gh)

  dim = dimsizes(var)
  wgt_var = new((/ dim(1),dim(2) /),typeof(var))

  wgt_var = 0                   ;intialize

  noflevels = 32
  do z = 0, noflevels, 1   ; z level

    lay_var = (var(z+1,:,:) + var(z,:,:)) ; interpolation of the variable
    lay_var = lay_var/2.

    dgh = gh(z+1,:,:) - gh(z,:,:) ; gh difference bw two layers
    dp = pres(z+1,:,:) - pres(z,:,:) ; pressure difference bw two layers

    lay_wgt = (dp/dgh)
    lay_wgt = lay_wgt * g     ;
    lay_wgt_var = lay_var * lay_wgt

    wgt_var = wgt_var + lay_wgt_var ;* 1/mean_levels)

  end do
  wgt_var = wgt_var * -1

  return(wgt_var)

end

;;--------------------------------------------------------------------
; this takes plots and arranges as panels
undef("panelize_2col")
function yag_draw_2d(var:numeric)
begin

  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 7             ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar

  pres@txString         = "Skin Temperature "      ; add common title
  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end
