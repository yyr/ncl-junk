; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
;    File: yagUtils.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Wednesday, September 21 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
; my dumb ncl functions/procedures

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;---------------------------------------------------------------------
; Fuction: announce
; Doc: just announces stdout what ever given with print statement
;---------------------------------------------------------------------
undef("announce")
procedure announce(var_in:string)
local str

begin
  str = var_in
  system("echo")
  system("echo ===========================================================")
  print(str+"")
  system("echo ===========================================================")

end
;- |announce| ends here --


;;--------------------------------------------------------------------
undef("yag_draw_2d")
function yag_draw_2d(var:numeric)
begin
  print(var)
end


;;--------------------------------------------------------------------
undef("no_of_levels")
function no_of_levels( f:file )
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
function panelize_2col(var:numeric)

begin
  wks = "test"
  pres                = True              ; mod panel plot
  pres@lbLabelStride  = 7             ; skip every other label
  pres@gsnPanelBottom = 0.05              ; add some space at bottom
  pres@gsnPanelLabelBar = True                   ; add common colorbar

  pres@txString         = "Skin Temperature "      ; add common title
;;  gsn_panel(wks,plot,(/noft/2 , 2/),pres)        ; create panel plot

end

;;--------------------------------------------------------------------
; function to retrieve diagnosis variable
; this is companion of wrf_user_getvar
;  T -> theta with removed offset
;  tc ->  tempereture in celcious [not yet implimented]
undef("wrf_my_getvar")
function wrf_my_getvar(file_handle,var_in:numeric,t_in:integer)
local test,fh,var,T,tin
begin
  fh = file_handle
  var = var_in(0)
  tin = t_in(0)
  if ( var .eq. "T" ) then
    T = wrf_user_getvar(fh,"T",tin)
    T = T + 300
    return(T)
  end if

  if ( var .eq. "tc" ) then
    return
  end if


end

;---------------------------------------------------------------------
; Fuction: set_inputfile
; Doc:
;
;---------------------------------------------------------------------
undef("set_inputfile")
function set_inputfile(env_in)
local env,fh
begin
  env=env_in
  if ( (env_in) ) then
    env = env_in
  else
    env = "NCL_FIN"
  end if
  fname = getenv(env)
  fh = addfile(fname,"r")
  return fh
end

;---------------------------------------------------------------------
; Fuction: draw_cs_line
; Doc:
;
;---------------------------------------------------------------------
undef("draw_cs_line")
function draw_cs_line(plane_in,opts:logical)
local t

begin


  return False
end
;- |draw_cs_line| ends here --

;---------------------------------------------------------------------
; Fuction: last
; Doc: returns the last index
;
;---------------------------------------------------------------------
undef("last")
function last(fh_in,varname_in:string,dim_in:integer)
local var,fh,var_in_file,last_ind,dim
begin
  varname= varname_in
  dim = dim_in

  if ( typeof(fh_in) .eq. "file" ) then
    ISFILE = True
    fh = fh_in
  else
    print("last: first argument is not a file handle")
    return
  end if

  dims = filevardimsizes(fh,varname)
  last_ind = dims(dim) - 1
  return last_ind

end
;- |last| ends here --

;---------------------------------------------------------------------
; Fuction: wrf_diff_slp2_xlevel
; Doc:
;
;---------------------------------------------------------------------
undef("wrf_diff_slp2_xlevel")
function wrf_diff_slp2_xlevel(fh_in,lev_in:integer)
local lev,fh_in,

begin




  return
end
;- "wrf_diff_slp2_xlevel" ends here --
