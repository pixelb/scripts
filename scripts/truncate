#!/bin/sh

# Increase or decrease the apparent size of a file

# License: LGPLv2
# Author:
#    http://www.pixelbeat.org/
# Notes:
#    There is a truncate command packaged with coreutils since v7.0,
#    and available on FreeBSD for ages. These are more functional as
#    they allow specifying relative sizes and mandating the file exists.
#    This is a thin wrapper around the truncate functionality of dd.
# Changes:
#    V1.0, 16 Dec 2005  Initial release

if [ "$#" != "2" ]; then
    (
    echo "
Usage: `basename $0` <size> <path>

Truncate the <path> to exactly <size> bytes.

If <path> doesn't exist it is created.

<size> is a number which may be optionally followed
by the following multiplicative suffixes:
  b              512
  KB            1000
  K             1024
  MB       1000*1000
  M        1024*1024
and so on for G, T, P, E, Z, Y

If the file previously was larger than this size, the extra data is
lost. If the file previously was shorter, it is extended
and the extended part reads as zero bytes. Note in both cases
no data is written (if the filesystem supports holes in files).

E.G.: truncate 2TB ext3.test
"
    ) >&2
    exit 1
fi

size=$1
file="$2"

error=`dd bs=1 seek=$size if=/dev/null of="$file" 2>&1`
ret=$?
echo "$error" | grep -v "^0" >&2
exit $ret
