#!/bin/sh

# Edit a file without changing its timestamps.
# Both access and modification times are maintained,
# or optionally those timestamps are set to a specific epoch.

# License: LGPLv2
# Author:
#    http://www.pixelbeat.org/
# Notes:
#    $EDITOR if set, must not fork at startup, so if you
#    want to use gvim for example, ensure EDITOR="gvim -f".
#    Currently linux can read timestamps with nanosecond resolution
#    but only set a specific timestamp with microsecond resolution
#    (if the filesystem even supports that).
# Changes:
#    V1.0, 31 May 2006, Initial release
#    V1.1, 13 Jul 2007, Allow specifying epoch
#                       Remove the use of temp files
#    V1.2, 24 Jul 2007, Fallback to second resolution for touch implementations
#                       that don't handle nanoseconds in the date string.
#                       Warn if nanosecond resolution is lost due to limitations
#                       in `touch`, the libc/kernel interface or the filesystem.
#    V1.3, 05 Feb 2009, Don't allow to specify epoch with leading + or -
#                       as it's common to call vim like: vim file +line_num etc.
#                       Only allow 2 parameters rather than ignoring extra ones.

file="$1"
epoch="$2"

if [ ! -f "$file" ] || [ $# -ne 1 -a $# -ne 2 ]; then
    echo "Usage: `basename $0` file [epoch]" >&2
    exit 1
fi

if [ ! "$epoch" ]; then
    epoch=`date --reference="$file" +%s.%N` || exit 1
else
    if echo "$epoch" | grep -Eq "^[\+-]"; then
        echo "Epochs with leading +/- are ambiguous with editor options" >&2
        exit 1
    fi
    if ! date --date="1970-01-01 UTC $epoch seconds" >/dev/null 2>&1; then
        echo "Invalid epoch specified [$epoch]" >&2
        exit 1
    fi
fi

if echo "$epoch" | grep -Fq "."; then #valid nanosecond format
    seconds=`echo $epoch | cut -d. -f1`
    if echo $epoch | grep -Eq "\.0+$"; then #strip redundant nanoseconds
        epoch=$seconds #since touch may not support nanosecond format
    else
        checkns="true" #need to check nanosecond portion later
    fi
fi
${EDITOR:-vim} "$file"
[ ! "$seconds" ] && err="/dev/tty" || err="/dev/null"
touch "$file" --date="1970-01-01 UTC $epoch seconds" 2>$err
if [ $? -ne 0 -a "$seconds" ]; then #maybe touch doesn't support nanoseconds
    touch "$file" --date="1970-01-01 UTC $seconds seconds" &&
    echo "Warning: sub second portion of timestamp ignored" >&2
else
    if [ "$checkns" ]; then
        new_ts=`date --reference="$file" +%s.%N`
        diff=`echo "(($epoch-$new_ts)*10^9)/1" | bc`
        if [ $diff -ne 0 ]; then
            echo "Warning: timestamp set ${diff}ns backwards" >&2
        fi
    fi
fi

#Hmm could have option to inc time by 1 second
#so that updates would be noticed as normal
#but the relative ordering of a file in time
#in relation to other files would probably be unchanged
