#!/usr/bin/python -i

# Enhance introspection at the python interactive prompt.
# This is a very simple alternative to ipython
# whose default settings I don't like.

# Notes:
#   You can run it directly, or call it like:
#     PYTHONSTARTUP=~/path/to/inpy python
# Changes:
#    V0.1      09 Sep 2008     Initial release
#    V0.2      30 Nov 2010
#      http://github.com/pixelb/scripts/commits/master/scripts/inpy


import os, errno
class _readline:
    history=os.path.join(os.environ['HOME'],'.inpy_history')
    import readline
    # turn on tab completion
    readline.parse_and_bind("tab: complete")
    import rlcompleter
    def __init__(self):
        try:
            self.readline.read_history_file(self.history)
        except (IOError, OSError), value:
            if value.errno == errno.ENOENT:
                pass
            else:
                raise
    def __del__(self):
        self.readline.write_history_file(self.history)
_rl=_readline()

import sys
# The following exits on Ctrl-C
def _std_exceptions(etype, value, tb):
    sys.excepthook=sys.__excepthook__
    if issubclass(etype, KeyboardInterrupt):
        sys.exit(0)
    else:
        sys.__excepthook__(etype, value, tb)
sys.excepthook=_std_exceptions

#try to import dire() and ls()
#See http://www.pixelbeat.org/libs/dir_patt.py
# Note if $PYTHONPATH is not set then you can
# import from arbitrary locations like:
#   import sys,os
#   sys.path.append(os.environ['HOME']+'/libs/')
try:
    from dir_patt import *
except:
    pass

#pprint.pprint() doesn't put an item on each line
#even if width is small? See also:
#http://code.activestate.com/recipes/327142/
#also from reddit:
#  ppdict = lambda d:"\n".join(map("%s: %s".__mod__, d.items()))
def ppdict(d):
    """Pretty Print for Dicts"""
    print '{'
    keys=d.keys()
    keys.sort()
    for k in keys:
        spacing=" " * (16-(len(repr(k))+1))
        print "%s:%s%s," % (repr(k),spacing,repr(d[k]))
    print '}'

if 0: # Show info on startup
    sys.stderr.write("Python %s\n" % sys.version.split('\n')[0])
    sys.stderr.write("Tab completion on. Available items: %s\n" %
                     sorted(filter(lambda n: not n.startswith('_'), locals())))
