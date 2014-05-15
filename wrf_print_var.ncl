; Created: Tuesday, March 25 2014

load "$nsc/yagUtils.ncl"
import("shea_util")

begin
  a = set_inputfile()
  var = a->ZNW

  printVarInfo(var,"")
;  print(var)

end
