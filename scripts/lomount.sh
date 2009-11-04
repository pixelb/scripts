#!/bin/sh

# Mount partitions within a disk image file

# Author: P@adraigBrady.com

# V1.0      29 Jun 2005     Initial release
# V1.1      01 Dec 2005     Handle bootable (DOS) parititons

if [ "$#" -ne "3" ]; then
    echo "Usage: `basename $0` <image_filename> <partition # (1,2,...)> <mount point>" >&2
    exit 1
fi

if ! fdisk -v > /dev/null 2>&1; then
    echo "Can't find the fdisk util. Are you root?" >&2
    exit 1
fi

FILE=$1
PART=$2
DEST=$3

UNITS=`fdisk -lu $FILE 2>/dev/null | grep $FILE$PART | tr -d '*' | tr -s ' ' | cut -f2 -d' '`
OFFSET=`expr 512 '*' $UNITS`
mount -o loop,offset=$OFFSET $FILE $DEST
