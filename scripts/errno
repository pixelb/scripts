#!/bin/sh

# Display ENAME corresponding to number
# or all ENAMEs if no number specified.

# License: LGPLv2

[ $# -eq 1 ] && re="$1([^0-9]|$)"
echo "#include <errno.h>" |
cpp -dD -CC | #-CC available since GCC 3.3 (2003)
grep -E "^#define E[^ ]+ $re" |
sed ':s;s#/\*\([^ ]*\) #/*\1_#;t s;' | column -t | tr _ ' ' | #align
cut -c1-$(tput cols) #truncate to screen width
