#!/bin/sh

# Mount partitions within a disk image file

# License: LGPLv2
# Author: P@adraigBrady.com

# V1.0      29 Jun 2005     Initial release
# V1.1      01 Dec 2005     Handle bootable (DOS) parititons
# v1.2      25 Jan 2013     Glen Gray: Handle GPT partitions

if [ "$#" -ne "3" ]; then
    echo "Usage: `basename $0` <image_filename> <partition # (1,2,...)> <mount point>" >&2
    exit 1
fi

FILE=$1
PART=$2
DEST=$3

if parted --version >/dev/null 2>&1; then # Prefer as supports GPT partitions
  UNITS=$(parted -s $FILE unit s print 2>/dev/null | grep " $PART " |
          tr -d 's' | awk '{print $2}')
elif fdisk -v >/dev/null 2>&1; then
  UNITS=$(fdisk -lu $FILE 2>/dev/null | grep "$FILE$PART " |
          tr -d '*' | awk '{print $2}')
else
  echo "Can't find the fdisk or parted utils. Are you root?" >&2
  exit 1
fi

OFFSET=`expr 512 '*' $UNITS`
mount -o loop,offset=$OFFSET $FILE $DEST
