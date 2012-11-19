;    File: mflux.ncl
;  Author: Yagnesh Raghava Yakkala <yagnesh@NOSPAM.live.com>
; Created: Tuesday, December 20 2011
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>
;

; Description:
;

load "$nsc/yagUtils.ncl"

begin
  tStrt = 50
  tLast = 144
  t = (tLast - tStrt) + 1
  print(t)
  lev =10

;***********************************************
;read in netcdf data
;***********************************************

  in =  addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

  q      = in->QVAPOR(tStrt:tLast,lev,:,:)
  v      = in->V(tStrt:tLast,lev,:,:)
  vlt    = in->V(:,lev,:,:)
  qlt    = in->QVAPOR(:,lev,:,:)
  v1     = in->V (:,1,:,:)
  u      = in->U(tStrt:tLast,lev,:,:)
  v2     = in->V (1,1,:,:)
  ;printVarSummary(q)

  ;***********************************************
; Deviation of v from time mean
;***********************************************
  v_tm = dim_avg_n_Wrap(vlt,0) ;do time average
  printVarSummary(v_tm)
  printMinMax(v_tm,True)
  vh = new((/t, 50, 144/), "double", getFillValue(v))
  do ti =0,t-1
    vh (ti,:,:) = v (ti,:,:) - v_tm(:,:)
  end do
  printVarSummary(vh)
  printMinMax(vh,True)
;*********************************************
; Deviation of q from time mean
;*********************************************
  q_tm = dim_avg_n_Wrap(qlt,0) ;do time average
  printVarSummary(q_tm)
  printMinMax(q_tm,True)
  qh = new((/t, 128, 256/), "double", getFillValue(q))
  do ti =0,t-1
    qh (ti,:,:) = q (ti,:,:) - q_tm(:,:)
  end do
  printVarSummary(qh)
  printMinMax(qh,True)

;***********************************************
; Deviation of u from time mean
;***********************************************
  u_tm = dim_avg_n_Wrap(u,0) ;do time average
  printVarSummary(u_tm)
  printMinMax(u_tm,True)
  uh = new((/t, 128, 256/), "double", getFillValue(u))
  do ti =0,t-1
    uh (ti,:,:) = u (ti,:,:) - u_tm(:,:)
  end do
  printVarSummary(uh)
  printMinMax(uh,True)

end
;;; mflux.ncl ends here
