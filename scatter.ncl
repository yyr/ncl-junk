import("yag_utils")

begin

  folders = (/"/home/yagnesh/wrf/run/20071116/d3" /)
  lev = 6

  hok  = (/262,117, 292,162/)
  sak  = (/292,162,335,232/)

  colors = (/"black","blue","red","green","orange","brown", "chocolate", "cornsilk4"/)

  do fol  = 0,dim_len0(folders) -1, 1   ;; folders
    print("entering the folder: " + folders(fol))
    a = addfile(folders(fol) + "/prof.nc","r")

    u = a->u_mean
    v = a->v_mean
    U = sqrt(u^2 + v^2)
    q = a->q
    q_wgt = new(dim_len0(q),"float")

    do it = 0, dim_len0(q) -1, 1
      q_wgt(it) = sum(q(it,:,:))
    end do

    x = q_wgt * 100
    print(q_wgt)

    x = where(x.lt.0.2, 0, x)

    x@_FillValue = 0
    xn = .not.ismissing(x)

    dim0 = dim_len0(x)
    min_length = 4

  end do
end
