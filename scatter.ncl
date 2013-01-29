load "$nsc/yagUtils.ncl"

begin
  a = addfile("prof.nc","r")

  u = a->u_mean
  v = a->v_mean
  scatdat = a->q

  wksSc=gsn_open_wks("ps","scatter")

  resS=True
  resS@gsnMaximize=True
  resS@xyMarkLineMode="Markers"
  resS@xyMarker=16

  scatter=gsn_xy(wksSc,u(:,1),v(:,1),resS)

end
