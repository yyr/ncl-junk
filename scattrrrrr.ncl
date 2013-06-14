load "$nsc/yagUtils.ncl"

begin

  folders = (/"/home/yagnesh/wrf/run/20071116/d3", \
              "/home/yagnesh/wrf/run/20071123/d3", \
              "/home/yagnesh/wrf/run/20071128/d3", \
              "/home/yagnesh/wrf/run/20071205/d3", \
              "/home/yagnesh/wrf/run/20071215/d3", \
              "/home/yagnesh/wrf/run/20071225/d3", \
              "/home/yagnesh/wrf/run/20071225/d3", \
              ; "/home/yagnesh/wrf/run/20080104/d3", \
              "/home/yagnesh/wrf/run/20080113/d3" \
              ; "/home/yagnesh/wrf/run/20080117/d3" \
              /)

  coard = (/92,218,213,372/)
  lo = coard(0)                      ; left lon
  ro = coard(1)                      ; right lon
  la = coard(2)                       ; left lat
  ra = coard(3)                      ; right lat

  lev = 6

  hok  = (/262,117, 292,162/)
  sak  = (/292,162,335,232/)

  wks=gsn_open_wks("ps","scatter1")

  res=True
  res@xyMarkLineMode="Markers"
  res@xyMarker  =  16
  res@gsnFrame = False

  res@trYMinF            = -20.
  res@trYMaxF            = 20.

  res@trXMinF            = -20.
  res@trXMaxF            = 20.

  res1 = res
  res1@trXMinF            = 0.
  res1@trXMaxF            = 20.
  res1@trYMinF            = 0.
  res1@trYMaxF            = 0.2

  colors = (/"black","blue","red","green","orange","brown", "chocolate", "cornsilk4"/)

  fil = systemfunc("ls ~/wrf/run/20071116/d3/wrfout*")
  out = addfile(fil,"r")

  xland = out->XLAND(0,lo:ro,la:ra)
  masking = where(xland .eq. 1 , 0 , 1)

  do fol  = 0,dim_len0(folders) -1, 1   ;; folders
    print("entering the folder: " + folders(fol))
    a = addfile(folders(fol) + "/prof.nc","r")
    band_times = asciiread(folders(fol) + "/band_times",-1,"integer")

    band_times = band_times - 1

    u = a->u_mean
    v = a->v_mean
    U = sqrt(u^2 + v^2)

    q = a->q
    q_wgt = new(dim_len0(q),"float")

    do it = 0, dim_len0(q) -1, 1
      q_wgt(it) = sum(q(it,:,:))
    end do

    x = q_wgt * 1000
    x = where(x.lt.0.2, 0, x)

    x@_FillValue = 0
    xn = .not.ismissing(x)

    res@xyMarkerColor = colors(fol)
    res1@xyMarkerColor = colors(fol)
    ; print(U(band_times,lev))
    ; print(q_wgt(band_times))
    scatter_q=gsn_csm_xy(wks,U(band_times,lev),q_wgt(band_times),res1)

    delete(band_times)
    delete(U)
    delete(a)
    delete(q_wgt)
    delete(q)

  end do
end
