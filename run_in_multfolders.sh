#!/bin/bash
#
#    File: run_in_multfolders.sh

declare -a directories=("/home/yagnesh/WRFMPI/WRFV3/test/bd/res"
    "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_topo/d3"
    "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_topo_saka/d3"
    "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_hok/d3"
    "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_sak/d3"
    "/home/yagnesh/WRFMPI/WRFV3/test/bd_no_hok_sak/d3")

for dir in ${directories[@]}; do
    cd $dir
    echo "running \"$@\" in $(pwd)..."
    $@
done

# run_in_multfolders.sh ends here
