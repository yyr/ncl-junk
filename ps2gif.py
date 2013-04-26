#!/usr/bin/env python
'''
--------------------------
Split ps/pdf and make it into gif. imagemagick giffing.

External commands required:
- psselect
- convert
--------------------------
'''

DATE = "Wednesday, April 24 2013"
AUTHOR = "Yagnesh Raghava Yakkala"
WEBSITE = "http://yagnesh.org"
LICENSE ="GPL v3 or later"

import re
import os.path
import subprocess

verb = False

def convert2gif(files,out_prefix,delay=50,density=50):
    if verb:
        print('running convert')
    ext = '.gif'
    of = out_prefix + ext
    cmd = 'convert -delay %d -density %d %s %s ' % (delay,density,' '.join(files), of)
    p = subprocess.Popen(cmd.split() ,stdout=subprocess.PIPE)
    p.wait()

class psFile(object):
    def __init__(self, fname):
        """Manipulate psFile
        Arguments:
        - `fname`: file name of ps file
        """
        self._fname = fname
        self._file_obj = open(self._fname,'r')
        self._no_pages = self.no_of_pages(self._file_obj)


    def no_of_pages(self,file_obj=None):
        """Search header and return number of pages of given ps file contain.
        """
        if file_obj is None:
            file_obj=self._file_obj

        for line in file_obj:
            m = re.match("%%Pages: (\d+)",line)
            if m:
                return(int(m.group(1)))

        return None

    def split2pages(self,fname=None,page_len=None,dry=False):
        if fname is None: fname=self._fname
        if page_len is None: page_len = self._no_pages

        fn, e = os.path.splitext(fname)
        page_files = []

        if verb: print('Started Splitting File.')

        for i in range(1,page_len + 1):
            of = fn + "-" + str(i) + e
            page_files.append(of)
            cmd = 'psselect -p%s %s %s' % (i,fname,of)
            if dry: continue
            if verb: print(cmd)
            p = subprocess.Popen(cmd.split() ,stdout=subprocess.PIPE)
            p.wait()

        return page_files


def arg_parse(file_name=None,dry=False,verbose=False,split_only=False):
    global verb
    verb = verbose
    for fn in file_name:
        fPath, f = os.path.split(fn)
        fName, fExn = os.path.splitext(f)
        psf = psFile(f)
        pages = psf.split2pages(dry=dry)
        if not split_only:
            convert2gif(pages,fName)


def main(args=None):
    import argparse
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawTextHelpFormatter,description=__doc__
    )
    parser.add_argument('file_name',nargs='+',
                        help='ps or pdf file(s) to convert to gif')
    parser.add_argument('-d','--dry',action='store_true')
    parser.add_argument('-v','--verbose',action='store_true')
    parser.add_argument('--split-only',action='store_true',
                        help='only split ps file')

    arg_parse(**vars(parser.parse_args(args)))


if __name__ == '__main__':
    main()
