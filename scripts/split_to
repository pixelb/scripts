#!/bin/sh

# split data from stdin to multiple invocations of a command
# without creating temporary files

# License: LGPLv2
# Author:
#    http://www.pixelbeat.org/
# Notes:
#    This script may be useful for chunking a stream before
#    sending to an FTP server supporting limited file sizes for e.g.
#      Using `ifne` from moreutils is not possible as it consumes BUFSIZ,
#    and doesn't indicate when no more data is available.  I.E. it's good
#    for conditional _single_ invocations of a command only.
# Changes:
#    V0.1, 29 Nov 2010, Initial release
#      http://github.com/pixelb/scripts/commits/master/scripts/split_to


if [ "$#" -lt 1 ]; then
  me=$(basename $0)
  echo "Usage: $me size [-n] [command]" >&2
  echo "split data from stdin to multiple invocations of a command" >&2
  echo >&2
  echo "   -n    pass the chunk number as the first parameter to command" >&2
  echo "Examples:" >&2
  echo "   $0 10000 'wc -c' < /bin/ls" >&2
  echo "   $0 10000 < /bin/ls" >&2
  echo "   $0 10000 -n < /bin/ls" >&2
  exit 1
fi

chunk_size=$1; shift
test "$1" = -n && { pass_part=1; shift; }
test "$1" && cmd="$*" || cmd=example_cmd

example_cmd() { echo "processing part $1 ($(wc -c) bytes)"; }

part=1
while true; do
  c=$(od -to1 -An -N1) # getc
  test "$c" || break
  c=$(echo $c) # trim
  test "$pass_part" && ppart=$part
  {
    printf "\\$c" # ungetc
    head -c$(($chunk_size-1))
  } | $cmd $ppart || break
  part=$(($part+1))
done
