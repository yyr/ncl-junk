import("yag_utils")

begin

  folders = (/"/home/yagnesh/wrf/run/20071116/d3", \
              "/home/yagnesh/wrf/run/20071123/d3", \
              "/home/yagnesh/wrf/run/20071128/d3", \
              "/home/yagnesh/wrf/run/20071205/d3", \
              "/home/yagnesh/wrf/run/20071215/d3", \
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

  lev = 20

  ; hok  = (/262,117 /)           ; ,292,162/)
  ; sak  = (/335,232/)

  line = (/117,232,262,335/)

  wks=gsn_open_wks("ps","scatter")
  wks1=gsn_open_wks("ps","scatter_q")
  wks2=gsn_open_wks("ps","scatter_tm")
  wks3=gsn_open_wks("ps","scatter_tm2")

  res=True
  res@xyMarkLineMode="Markers"
  res@xyMarker  =  16
  res@gsnFrame = False

  res@trYMinF            = -30.
  res@trYMaxF            = 50.

  res@trXMinF            = -20.
  res@trXMaxF            = 80.

  res1 = res
  res1@trXMinF            = 0.
  res1@trXMaxF            = 20.
  res1@trYMinF            = 0.
  res1@trYMaxF            = 0.2

  res2 = res
  res2@trXMinF            = -10.
  res2@trXMaxF            = 10.
  res2@trYMinF            = 0.
  res2@trYMaxF            = 0.2

  colors = (/ \
             "blue", \
             "black", \
             "cornsilk4", \
             "red",  \
             "green", \
             "orange",\
             "brown", \
             "chocolate" \
             /)

  markers = (/ \
              "*" , \
              "dot" , \
              "+" , \
              "plus" , \
              "asterisk" , \
              "hollow_circle" , \
              "cross" , \
              "x" \
              /)

  fil = systemfunc("ls ~/wrf/run/20071116/d3/wrfout*")
  out = addfile(fil,"r")

  xland = out->XLAND(0,lo:ro,la:ra)
  masking = where(xland .eq. 1 , 0 , 1)

  do fol  = 0,dim_len0(folders) -1, 1   ;; folders
    print("entering the folder: " + folders(fol))
    a = addfile(folders(fol) + "/prof.nc","r")

    t2 = a->T2

    t2_hok = new(dim_len0(t2),float)
    t2_sak = new(dim_len0(t2),float)

    do it = 0, dim_len0(t2) -1, 1
      t2_line = wrf_user_intrp2d(t2(it,:,:),line,0.,True)
      t2_line_max = max(t2_line)

      t2_hok(it) = t2(it,117,262) - t2_line_max
      t2_sak(it) = t2_line_max - t2(it,232,335)

      ; t2_hok(it) = t2_line(0) - t2_line_max
      ; t2_sak(it) = t2_line(dim_len0(t2_line) -1) - t2(it,232,335)

      print(it + " " + t2_line_max + " "+ t2(it,117,262) + " " + t2(it,232,335) )
      delete(t2_line)

    end do

    ; t2_hok = t2(:,117,262) - t2(:,162,292)

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
    res1@xyMarkerColor = colors(fol)
    res2@xyMarkerColor = colors(fol)
    ; res@xyMarker  = fol * 2

    scatter=gsn_csm_xy(wks,u(band_times,lev),v(band_times,lev),res)
    scatter_q=gsn_csm_xy(wks1,U(band_times,lev),q_wgt(band_times),res1)
    scatter_tm=gsn_csm_xy(wks2,t2_hok(band_times),q_wgt(band_times),res2)
    scatter_tm2=gsn_csm_xy(wks3,t2_sak(band_times),q_wgt(band_times),res2)

    delete(band_times)
    delete(U)
    delete(a)
    delete(q_wgt)
    delete(q)

  end do
end
