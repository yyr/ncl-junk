load "$nsc/yagUtils.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"

begin
;
; The WRF ARW input file.
; This needs to have a ".nc" appended, so just do it.
  a = addfile("./wrfout_d03_2008-12-25_00:00:00.nc","r")

; station lat lons ij (180,87),(199,208) (241,139)
; lon: 143.365, 143.769,144.526
; lat: 44.4966, 46.1213,45.1733

; We generate plots, but what kind do we prefer?
;  type = "x11"
; type = "pdf"
  type = "ps"
; type = "ncgm"
;  wks = gsn_open_wks(type,"SkewT_26_11")
;  wks = gsn_open_wks(type,"SkewT_26_22")
;  wks = gsn_open_wks(type,"SkewT_27_11")
  wks = gsn_open_wks(type,"SkewT_A")

  gsn_define_colormap(wks,"WhViBlGrYeOrReWh")

; What times and how many time steps are in the data set?
  FirstTime = True
  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

; Get some dimension info - so we can later check to make sure
; the sounding locations are inside the model domain
  mdims = getfilevardimsizes(a,"P")
  nd = dimsizes(mdims)
  dimX = mdims(nd-1)
  dimY = mdims(nd-2)


  do it = 70, 134,2 ; at 11       ; TIME LOOP
    print("Working on time: " + times(it) )

    tc  = wrf_user_getvar(a,"tc",it)         ; T in C
    td  = wrf_user_getvar(a,"td",it)         ; dew point temperature
    p   = wrf_user_getvar(a, "pressure",it)  ; grid point pressure
    z   = wrf_user_getvar(a, "z",it)         ; grid point height
    uvm = wrf_user_getvar(a,"uvmet",it)      ; umet and vmet averaged to mass points
    ; This is a 4D array where
    ; uvm(0,:,:,:) is umet, and
    ; uvm(1,:,:,:) is vmet, and
    ; This function rotate winds to earth coord.

    ; extract u and v from uvm array, and turn wind into kts
    u   = uvm(0,:,:,:)*1.94386
    v   = uvm(1,:,:,:)*1.94386

    ; Stations, and their lat/lon locations

    ip_locs = (/ "StationA", "StationB", "StationC"/)

    ip_lats = (/ 44.4966, 46.1213,45.1733 /)

    ip_lons = (/ 143.365, 143.769,144.526 /)


    do ip = 2, 2  ; LOOP through above 3 station
      ; plot a skewT if location is inside model domain
      ; Get ij point in model domain for location "ip"
      ; loc(1) is south-north (y) and loc(0) is west-east (x)
      loc = wrf_user_ll_to_ij(a, ip_lons(ip), ip_lats(ip), True)
      locX = loc(0)
      locY = loc(1)

      if ( locX .lt. 1 .or. locX .gt. dimX .or. locY .lt. 1 .or. locY .gt. dimY )
        if ( FirstTime)
          print("Attempting to plot: " + "Station - " + ip_locs(ip) )
          print("                    " + "at location: "+ ip_lats(ip) +" ; "+ ip_lons(ip) )
          print("                    " + "SKIP: Sounding outside model domain" )
        end if
      else

        ; We need array points in NCL space
        locX = locX - 1
        locY = locY - 1

        ;      Define a few skew-T plotting options
        skewtOpts          = True
        skewtOpts@DrawHeightScale   = True    ; plot height scale on side
        skewtOpts@DrawHeightScaleFt = False   ; plot height scale in km
        skewtOpts@DrawStandardAtm   = True    ; draw standard atm on plot
        skewtOpts@vpXF              = 0.12    ; controls off-set from left
        skewtOpts@vpYF              = 0.87    ; controls off-set from top
        skewtOpts@vpWidthF          = 0.75    ; controls size of plot
        skewtOpts@vpHeightF         = 0.75    ; controls size of plot
        skewtOpts@DrawFahrenheit    = False   ; use deg C scale
        skewtOpts@tiMainFontHeightF = 0.015   ; change height of main title
        ;skewtOpts@DrawColLine       = False   ; draw lines in black
        skewtOpts@DrawColAreaFill   = True    ; color on background plot
        ;skewtOpts@DrawColAreaColor  = "Green" ; final color may depend on the color table used
        skewtOpts@DrawColAreaColor  = 53      ; Light Green for WhViBlGrYeOrReWh color table
        skewtOpts@PrintOpts         = False   ; do not print options out


        ;      Get the skew-T background
        skewtOpts@tiMainString = ip_locs(ip)  + " at " + times(it)
        skewt_bkgd             = skewT_BackGround (wks, skewtOpts)
        draw (skewt_bkgd)


        ;      Draw the skew-T plot
        dataOpts           = True
        dataOpts@Parcel    = 1
        dataOpts@WspdWdir  = False  ; wind speed and dir [else: u,v]
        dataOpts@HspdHdir  = True   ; wind speed and dir [else: u,v]
        dataOpts@PlotWindH = False  ; plot wind barbs at h lvls [pibal; special]
        skewT_data = skewT_PlotData(wks, skewt_bkgd, p(:,locY,locX), \
                                    tc(:,locY,locX), \
                                    td(:,locY,locX), \
                                    z(:,locY,locX), \
                                    u(:,locY,locX), \
                                    v(:,locY,locX), \
                                    dataOpts)

        ;      Close the frame
        frame(wks)

        delete(skewtOpts)
        delete(dataOpts)
        delete(skewT_data)
        delete(skewt_bkgd)

      end if

    end do     ; END OF LOCATIONS

    FirstTime = False

  end do

end
