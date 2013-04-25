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
import os.path

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

    def split2pages(self,fname=None,page_len=None):
        if fname is None:
            fname=self._fname
        if page_len is None:
            page_len = self._no_pages

        import subprocess
        fn, e = os.path.splitext(fname)
        page_files = []
        print('Started Splitting File.')
        for i in range(1,page_len + 1):
            of = fn + "-" + str(i) + e
            page_files.append(of)
            cmd = 'psselect -p%s %s %s' % (i,fname,of)
            p = subprocess.Popen(cmd.split() ,stdout=subprocess.PIPE)
            p.wait()

        return page_files


def arg_parse(file_name=None):
    for fn in file_name:
        fPath, f = os.path.split(fn)
        fName, fExn = os.path.splitext(f)
        psf = psFile(f)
        psf.split2pages()


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
