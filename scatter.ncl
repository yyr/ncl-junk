load "$nsc/yagUtils.ncl"

begin
  a = addfile("prof.nc","r")

  u = a->u_mean
  v = a->v_mean
  q = a->q
  q_wgt = new(dim_len0(q),"float")

  do it = 0, dim_len0(q) -1, 1
    q_wgt(it) = sum(q(it,:))
  end do

  lev = 1


  x = q_wgt * 1000
  x = where(x.lt.0.2, 0, x)
  ; u(:,lev) = where(x.eq.0, 0, u(:,lev))
  ; v(:,lev) = where(x.eq.0, 0, v(:,lev))

  fin = (/x,u(:,lev),v(:,lev)/)

  count= 0

  x@_FillValue = 0
  xn = .not.ismissing(x)

  dim0 = dim_len0(x)

  min_length = 4

  wks=gsn_open_wks("ps","scatter")
  res=True
  res@xyMarkLineMode="Markers"
  res@xyMarker  =  16
  res@xyMarkerSizeF = 0.005

  res@trYMinF            = -20.
  res@trYMaxF            = 20.

  res@trXMinF            = -20.
  res@trXMaxF            = 20.



  i = 0                         ; main iterator
  j = 0                         ; for assainging values
  do while ( i .lt. dim0 )
    ; print("i: " +  i)
    edge = find_edge(xn,i,dim0 - 1)
    ; a_grouped(j,0:edge-i) = a(i:edge)

    if ( edge - i .ge. 4 .and. xn(i) ) then
      print(x(i:edge))
      scatter=gsn_csm_xy(wks,u(i:edge,1),v(i:edge,1),res)
    end if


    ; forward iterator
    if ( i .eq. edge ) then
      i = i + 1
    else
      i = edge + 1
    end if
    j = j + 1
  end do

end
