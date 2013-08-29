#!/bin/bash
#
#    File: gen_tags.sh
# Created: Friday, July 27 2012
#

# Description:
rm TAGS

gen-tags.sh $(pwd)
gen-tags.sh $NCARG_ROOT/lib/ncarg/nclscripts/
gen-tags.sh ~/nsc/ncl-lib/

# gen_tags.sh ends here
