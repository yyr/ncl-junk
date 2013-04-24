#!/usr/bin/env python
'''
Split ps/pdf and make it into gif. imagemagick giffing.

External commands required:
- psselect
- convert
'''

DATE = "Wednesday, April 24 2013"
AUTHOR = "Yagnesh Raghava Yakkala"
WEBSITE = "http://yagnesh.org"
LICENSE ="GPL v3 or later"

import re
def ps_nopages(file_obj):
    """Search header and return number of pages of given ps file contain.
    """
    for line in file_obj:
        m = re.match("%%Pages: (\d+)",line)
        if m:
            return(m.group(1))

    return None

def arg_parse(file_name=None):
    import os.path
    for fn in file_name:
        fPath, f = os.path.split(fn)
        fName, fExn = os.path.splitext(f)
        print(f + " " + ps_nopages(open(f,'r')))

def main(args=None):
    import argparse
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawTextHelpFormatter,description=__doc__
    )
    parser.add_argument('file_name',nargs='+',
                        help='ps or pdf file(s) to convert to gif')
    arg_parse(**vars(parser.parse_args(args)))


if __name__ == '__main__':
    main()
