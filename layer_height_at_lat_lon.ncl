; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
; Created: Friday, March  8 2013
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>

load "$nsc/yagUtils.ncl"

begin
  a = set_inputfile()

  lon = 143.3
  lat = 45.6845
  ; ilon = 275                    ; 143.3
  ; ilat = 214                    ; 45.6845

  ll = wrf_user_ij_to_ll(a,ilon,ilat,True)
  ij = wrf_user_ll_to_ij(a,lon,lat,True)

  hgt = wrf_user_getvar(a,"height", 1)

  print(hgt(:,ij(0),ij(1)))
  print(hgt(:,ij(0),ij(1)))

end
