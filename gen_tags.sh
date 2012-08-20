#!/bin/bash
#
#    File: gen_tags.sh
# Created: Friday, July 27 2012
#

# Description:

script="/home/yagnesh/.emacs.d/el-get/ncl-mode/ncl-ctags-gen.sh"

## delete previously generated one.
rm TAGS

$script .
$script ~/local/ncl/lib/ncarg/nclscripts/
# gen_tags.sh ends here
