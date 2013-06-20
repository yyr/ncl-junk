import("yagUtils")

begin
  a = addfile("prof.nc","r")
  fil = systemfunc("ls wrfout*")
  out = addfile(fil,"r")

  ofname = "tmp.nc"
  system("rm -f " + ofname)
  o =  addfile(ofname, "c")
  filedimdef(o,"Time", -1,True)

  coard = (/92,218,213,372/)
  lo = coard(0)                      ; left lon
  ro = coard(1)                      ; right lon
  la = coard(2)                      ; left lat
  ra = coard(3)                      ; right lat

  lon = out->XLONG(0,lo:ro,la:ra) ;fixed domain
  lat = out->XLAT(0,lo:ro,la:ra)  ; ditto
  xland = out->XLAND(0,lo:ro,la:ra)
  masking = where(xland .eq. 1 , 0 , 1)

  q = a->q

  do it = 0, dim_len0(q) - 1 , 1
    q(it,:,:) = q(it,:,:) * masking
  end do

end
