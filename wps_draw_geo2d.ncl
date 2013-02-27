;    File: wps_draw_geo2d.ncl
;  Author: Yagnesh Raghava Yakkala <hi@yagnesh.org>
; Created: Saturday, October 22 2011

; Description:
; draw 2d fields from wrfout

load "$nsc/yagUtils.ncl"

begin

  a = addfile("./geo_em.d01.nc","r")

  vname = getfilevarnames (a)

  dummy = "y"

  print("Enter a Variable name:")
  var = systemfunc("read ans; echo $ans")

  if ( .not. isfilevar(a,var) ) then
    print(var + "is not a file Varialbe")
  end if

  do while ( dummy .eq. "y" )
    type = "x11"
    ; type = "ps"
    wks = gsn_open_wks(type,"plt_geo")

    res = True
    res@MainTitle = "GEOGRID FIELDS"
    res@InitTime = False
    res@Footer = False

    pltres = True

    mpres = True
    mpres@mpGeophysicalLineColor = "Black"
    mpres@mpNationalLineColor    = "Black"
    mpres@mpUSStateLineColor     = "Black"

    gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
    v = a->$var$

    opts = res
    opts@cnFillOn = True
    opts@cnFillMode = "AreaFill"

    ; Set special plot options depending on the variable
    if ( var .eq. "SLOPECAT")
      opts@cnFillMode       = "RasterFill"
      opts@ContourParameters = (/ 1,7,1 /)
    end if

    if ( var .eq. "SOILTEMP")
      opts@ContourParameters = (/ 280.,295.,0.25 /)
    end if

    if ( var .eq. "LU_INDEX")
      gsn_define_colormap(wks,"StepSeq25")
      opts@cnFillMode       = "RasterFill"
      opts@cnExplicitLabelBarLabelsOn = True
      opts@ContourParameters = (/ 2,24,1 /)
      opts@lbLabelStrings = (/ "Urban and Built-Up Land", "Dryland Cropland and Pasture", \
                              "Irrigated Cropland and Pasture", "Mixed Dryland/Irrigated Cropland", \
                              "Cropland/Grassland Mosaic", "Cropland/Woodland Mosaic", "Grassland", \
                              "Shrubland", "Mixed Shrubland/Grassland", "Savanna", \
                              "Deciduous Broadleaf Forest", "Deciduous Needleleaf Forest", \
                              "Evergreen Broadleaf Forest", "Evergreen Needleleaf Forest", \
                              "Mixed Forest", "Water Bodies", "Herbaceous Wetland", "Wooded Wetland", \
                              "Barren or Sparsely Vegetated", "Herbaceous Tundra", "Wooded Tundra", \
                              "Mixed Tundra", "Bare Ground Tundra", "Snow or Ice" /)
      opts@lbLabelAngleF = 270.0
      opts@lbLabelAlignment = "BoxCenters"
      opts@lbTitleOn = False
      opts@lbLabelFontHeightF = 0.01
      opts@lbLabelJust = "CenterLeft"
      opts@pmLabelBarOrthogonalPosF = 0.01
    end if

    if ( var .eq. "LANDMASK")
      colors = (/"white", "black", "White", "DeepSkyBlue", "ForestGreen"/)
      gsn_define_colormap(wks, colors)
      opts@cnFillMode       = "RasterFill"
      opts@lbLabelBarOn = False
      opts@ContourParameters = (/ 0,1,1 /)
      opts@cnFillColors         = (/"White","DeepSkyBlue", "ForestGreen"/)
    end if

    dimv = dimsizes(v)        ; dimension size of the variable
    rank = dimsizes(dimv)     ; rank [ie: number of dimensions]

    dNames = getfilevardims(a,var)
    ndnames = dimsizes(dNames)
    if ( dNames(ndnames-1) .eq. "west_east" .and. dNames(ndnames-2) .eq. "south_north" ) then  ; only plot unstaggered variables
      if ( rank .eq. 3 ) then
        print (var)       ; print variable name
        opts@FieldTitle = var +" : "+ v@description   ; overwrite field name
        contour = wrf_contour(a,wks,v(0,:,:),opts)
        plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
      end if
      if ( rank .eq. 4 ) then
        print (var)       ; print variable name
        print(var + "is 3 dimentional variable")
      end if
    end if

    delete (v)
    delete (dimv)
    delete (rank)
    delete (opts)
    delete (dNames)
    delete(wks)

    ;;-- get a new var to display  --
    print(vname)
    print("Enter a Variable name:")
    var = systemfunc("read ans; echo $ans") ;stringtointeger()
    if ( .not. isfilevar(a,var) ) then
      print(var + "is not a file Varialbe")
    end if

  end do
end
