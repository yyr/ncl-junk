load "$nsc/yagUtils.ncl"

begin

  folders = (/"/home/yagnesh/wrf/run/20071116/d3", \
              "/home/yagnesh/wrf/run/20071123/d3", \
              "/home/yagnesh/wrf/run/20071128/d3", \
              "/home/yagnesh/wrf/run/20071205/d3", \
              "/home/yagnesh/wrf/run/20071215/d3", \
              "/home/yagnesh/wrf/run/20071225/d3", \
              ; "/home/yagnesh/wrf/run/20080104/d3" \
              "/home/yagnesh/wrf/run/20080113/d3" \
              ; "/home/yagnesh/wrf/run/20080117/d3" \
              /)

  lev = 2

  wks=gsn_open_wks("ps","scatter")
  res=True
  res@xyMarkLineMode="Markers"
  res@xyMarker  =  16
  res@xyMarkerSizeF = 0.005

  res@trYMinF            = -20.
  res@trYMaxF            = 20.

  res@trXMinF            = -20.
  res@trXMaxF            = 20.
  res@gsnFrame = False
  res@gsnFrame = False

  do fol  = 0,dim_len0(folders) -1, 1   ;; folders

    print("entering the folder: " + folders(fol))
    a = addfile(folders(fol) + "/prof.nc","r")

    u = a->u_mean
    v = a->v_mean
    q = a->q
    q_wgt = new(dim_len0(q),"float")
    q_wgt = q_wgt * b_a         ; normalize over land points


    do it = 0, dim_len0(q) -1, 1
      q_wgt(it) = sum(q(it,:))
    end do

    x = q_wgt * 1000
    x = where(x.lt.0.2, 0, x)

    x@_FillValue = 0
    xn = .not.ismissing(x)

    dim0 = dim_len0(x)
    min_length = 4

    i = 0                         ; main iterator
    j = 0                         ; for assainging values
    do while ( i .lt. dim0 )
      ; print("i: " +  i)
      edge = find_edge(xn,i,dim0 - 1)

      if ( edge - i .ge. 4 .and. xn(i) ) then
        ; print(x(i:edge))
        scatter=gsn_csm_xy(wks,u(i:edge,lev),v(i:edge,lev),res)
      end if

      ; forward iterator
      if ( i .eq. edge ) then
        i = i + 1
      else
        i = edge + 1
      end if
      j = j + 1
    end do
  end do

  draw(wks)
  frame(wks)
end
