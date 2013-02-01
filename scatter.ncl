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

  x = q_wgt * 1000
  x = where(x.lt.0.2, 0, x)
  u(:,1) = where(x.eq.0, 0, u(:,1))
  v(:,1) = where(x.eq.0, 0, v(:,1))

  wks=gsn_open_wks("ps","scatter")
  res=True
  res@xyMarkLineMode="Markers"
  res@xyMarker=16

  scatter=gsn_csm_xy(wks,u(:,1),v(:,1),res)

end
