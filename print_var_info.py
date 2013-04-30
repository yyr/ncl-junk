#!/usr/bin/env python
'''

'''

DATE = "Tuesday, April 30 2013"
AUTHOR = "Yagnesh Raghava Yakkala"
WEBSITE = "http://yagnesh.org"
LICENSE ="GPL v3 or later"

import os
import fnmatch
import sys

import Nio

wrf_dom = 3

def set_inputfile(wrf_dom):
    for f in os.listdir('.'):
        if fnmatch.fnmatch(f, 'wrfout*' + 'd0' + str(wrf_dom) + '*'):
            return f
        else:
            print("couldn't find wrfout file in the folder.")
            sys.exit()


def print_var_summary(f):
    ncfile = Nio.open_file(f,format='nc')
    print(ncfile)


def main():
    print_var_summary(set_inputfile(wrf_dom))

if __name__ == '__main__':
    main()
