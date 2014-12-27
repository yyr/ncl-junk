; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
; Created: Tuesday, August  6 2013
; License: GPL v3 or later. <http://www.gnu.org/licenses/gpl.html>

load "$nsc/yagUtils.ncl"

begin
  a = set_inputfile()
  type = "pdf"

  wks = gsn_open_wks(type,"cs_th")

  planes = (/(/217,378,98,372/),(/252,350,80,301/), (/300,378,56,176/) , \
             (/303,382,62,237/), (/191,215,122,168/)/)

  plane = new(4,float)
  plane = planes(3,:)

  angle = 0.                    ; intialize
  angle = angle_with_horizontal(plane(0),plane(1),plane(2),plane(3))
  level = 950

  res = True
  res@trYMaxF = 273
  res@trYMinF = 267
  res@trXMaxF = 160
  res@xyLineThicknessF = 2.
  times  = wrf_user_list_times(a)          ; Get times in the file

  do it = 95,95
    print("Working on time: " + times(it) )

    th  = wrf_user_getvar(a,"th",it)
    T = wrf_user_getvar(a,"tc",it)
    p  = wrf_my_getvar(a, "pressure",it)

    th_level = wrf_user_intrp3d(th,p,"h",level,0.,True)
    th_line = wrf_user_intrp2d(th_level,plane,angle,True)

    printVarSummary(th_line)
    th_line = where(th_line.gt.500, th_line@_FillValue,th_line)

    plot = gsn_csm_y(wks,th_line(0:160),res)

  end do
end
