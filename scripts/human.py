#!/usr/bin/env python

# Convert a number for human consumption

# Author:
#    P@draigBrady.com
# Changes:
#    V1.0      09 Jan 2006     Initial release

#TODO: support ranges for --column option
#TODO: support converting from back from "human" numbers to "standard" numbers
#TODO: support aligning output like `column -t`
#TODO: support --col-delimiters option

# Divisor can be 1, 1000, 1024
#
# A divisor of 1 => the thousands seperator
# appropriate to ones locale is inserted.
# So the locale must be set before this
# functionality is used (see below).
#
# With other divisors the output is aligned
# in a 7 or 8 character column respectively,
# which one can strip() if the display is not
# using a fixed width font.
def human_num(num, divisor=1, power=""):
    num=float(num)
    if divisor == 1:
        return locale.format("%ld",int(num),1)
    elif divisor == 1000:
        powers=[" ","K","M","G","T","P"]
    elif divisor == 1024:
        powers=["  ","Ki","Mi","Gi","Ti","Pi"]
    else:
        raise ValueError, "Invalid divisor"
    if not power: power=powers[0]
    while num >= 1000: #4 digits
        num /= divisor
        power=powers[powers.index(power)+1]
        human_num(num,divisor,power)
    if power.strip():
        return "%6.1f%s" % (num,power)
    else:
        return "%4ld  %s" % (num,power)

import locale
locale.setlocale(locale.LC_ALL,'')

import os
import sys
import getopt
def Usage():
    print "Usage: %s [OPTION] [PATH]" % os.path.split(sys.argv[0])[1]
    print "    --divisor=value   The default value is 1 which means insert thousands seperator."
    print "                      Other possible values are 1000 and 1024."
    print "    --columns=1,2,3"
    print "    --help            display help"

try:
    lOpts, lArgs = getopt.getopt(sys.argv[1:], "", ["help","divisor=","columns="])

    if len(lArgs) == 0:
        infile = sys.stdin
    elif len(lArgs) == 1:
        infile = file(lArgs[0])
    else:
        Usage()
        sys.exit(None)

    if ("--help","") in lOpts:
        Usage()
        sys.exit(None)

    divisor=1
    columns=[]
    for opt in lOpts:
        if opt[0] == "--divisor":
            divisor=opt[1]
            if divisor == "1":
                divisor = 1
            elif divisor=="1000" or divisor=="1024":
                divisor = float(divisor)
            else:
                raise getopt.error, "Invalid divisor"
        if opt[0] == "--columns":
            columns=[int(col) for col in opt[1].split(",")]

except getopt.error, msg:
    print msg
    print
    Usage()
    sys.exit(2)

for line in infile:
    line = line.split()
    column=0
    for str in line:
        column+=1
        if not len(columns) or column in columns:
            try:
                str = human_num(str,divisor)
            except:
                pass
        print str,
    print
