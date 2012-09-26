#!/usr/bin/env python

# Show top disk space users in current directory,
# while automatically recursing down directories if
# there is one obvious directory using the space.

# License: LGPLv2
# Author: P@draigBrady.com

#Design decisions:
# 1. Don't show tree as can only view one level at a time
#    You could use a treemap, where you can see large files
#    anywhere on disk. However the size is relative to all
#    files on disk and not current level, which IMHO is usually
#    what's required and easier to navigate.
# 2. Note I rerun du when browsing into directories. I.E.
#    I don't cache the tree locally. This is because the
#    kernel will do this anyway, so why duplicate code & data?

#TODO:
# hardlink doesn't have to be in the same directory at all,
# but since only showing one, then flag warning saying more
# than 1 link => do exhaustive search to del all? or just
# redisplay next name if hardlink in current directory.
#
# Set (background?) colour like batt_stat?
#
# ' in filenames will cause probs

import os
import sys
import operator

cutoff_percentage=5

#The following matches "du -h" output
def human(num, power="K"):
    powers=["K","M","G","T"]
    while num >= 1000:
        num /= 1024.0
        power=powers[powers.index(power)+1]
        human(num,power)
    return "%.1f%s" % (num,power)

def print_du(path):
    dufile=os.popen('find \'' + path + '\' -maxdepth 1 -mindepth 1 \( -type f -o -type l -o -type d \) -print0 | xargs -r0 du --max-depth 0 -k | grep -v "^0"')
    dulist=dufile.readlines()
    if len(dulist) == 0: #file specified
        sys.exit(0)
    filedict={}
    for line in dulist:
        size,name = line[:-1].split('\t',2)
        stat_val = os.stat(name)
        filedict.setdefault((int(size), stat_val.st_ino),[]).append(name)
    dulist=None

    keys = filedict.keys()
    keys.sort() #dict randomizes keys
    keys.reverse()
    total=reduce(operator.add, [item[0] for item in keys])
    found_one=0
    for key in keys:
        size=key[0]
        percentage = size*100/total
        if percentage < cutoff_percentage:
            continue
        names = filedict[key][:]
        name = names[0]
        isdir=os.path.isdir(name)
        if isdir and (percentage > (100-cutoff_percentage)): #nothing of interest @ this level
            filedict=None;keys=None
            if print_du(name):
                return 1
        found_one=1
        print "%2d%%%10s    " % (percentage, human(size)),
        for name in names:
            if isdir:
                sys.stdout.write("\033[01;34m")
            print name,
        print "\033[00m"
    return found_one

if len(sys.argv) == 1:
    sys.argv.append('.')

print_du(sys.argv[1])
