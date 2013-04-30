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

def set_inputfile(wrf_dom):
    for f in os.listdir('.'):
        if fnmatch.fnmatch(f, 'wrfout*' + 'd0' + str(wrf_dom) + '*'):
            return f
        else:
            print("couldn't find wrfout file in the folder.")
            sys.exit()


def print_var_summary(f,varname=None):
    ncfile = Nio.open_file(f,format='nc')
    if varname is not None:
        try:
            print(ncfile.variables[varname])
        except KeyError:
            print('\nWARNING: no such variable called "%s"; listing all vars' % varname)
            print('  ' + '\n  '.join(ncfile.variables.keys()))

def arg_parse(varname=None,domain=None):
    wrf_dom = 3
    if varname is not None:
        for var in varname:
            print_var_summary(set_inputfile(wrf_dom),varname=var)


    return


def main(args=None):
    import argparse
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawTextHelpFormatter,
        description=__doc__)
    parser.add_argument('varname', nargs='*',
                        help='Variable name(s) for query.')
    parser.add_argument(
        '--domain', type=int, default=3, help=
        'Domain number eg: { 1, 2, 3}. (For searching input file)')

    arg_parse(**vars(parser.parse_args(args)))


if __name__ == '__main__':
    main()
