#!/bin/sh

# list files last modified in a given month & year.

# License: LGPLv2
# Author:
#    http://www.pixelbeat.org/
# Changes:
#    V0.1, 08 Jul 2004, Initial release
#    V0.2, 04 Oct 2007, Fix reporting for files close to month boundaries
#                       Fix reporting for current month
#                       Support reporting of future dates
#                       Better error checking

if [ "$#" -lt 2 ]; then
    echo "Usage: `basename $0` MM YYYY [other find parameters]" >&2
    exit 1
fi

set -e #exit early on error

month=$1
year=$2
shift; shift

if [ "$month" = "12" ]; then
    next_year=`expr $year + 1`
    next_year=`printf "%02d" $next_year` #date requires YY not Y
    next_month=1
else
    next_year=$year
    next_month=`expr $month + 1`
fi
now=`date --utc +%s`
start=`date --date="$year-$month-01 UTC" +%s`
end=`date --date="$next_year-$next_month-01 UTC" +%s`

if [ $start -gt $now ]; then
    start=$now
    end=""
elif [ $end -gt $now ]; then
    end=""
fi

start_days_ago=`expr \( $now - $start \) / 86400`
start_days_ago=`expr $start_days_ago + 1`
if [ "$end" ]; then #faster
    end_days_ago=`expr \( $now - $end \) / 86400`
    find "$@" -daystart -mtime -$start_days_ago -mtime +$end_days_ago
else
    [ `echo -n $month | wc -c` -eq 1 ] && month="0$month"
    [ `echo -n $year | wc -c` -eq 2 ] && year="20$year"
    find "$@" -daystart -mtime -$start_days_ago -printf "%p\0%Tm-%TY\n" |
    LANG=C grep -a "$month-$year$" |
    cut -d '' -f1
fi
