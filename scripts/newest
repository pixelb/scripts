#!/bin/sh

# List the newest files in the specified paths and by default any subdirectories
# If no paths are specified, the current directory is listed.

# License: LGPLv2
# Author:
#    http://www.pixelbeat.org/
# Notes:
#    This script explicitly ignores repository metadata.
#    This script (well find actually) fails for user specified paths
#    that begin with '-', '(' or '!', so prepend './' for paths like that.
# Changes:
#    V1.0, 26 May 2005, Initial release
#    V1.1, 20 Jul 2007, Ignore git metadata in addition to svn and cvs
#                       Fix options syntax (breaks backwards compatibility)
#                       Add -nr option to not recurse
#                       Add -na option to ignore dotfiles
#                       Add -r option to show oldest rather than newest
#                       Allow specifying multiple files & directories
#                       Don't output extra file info if output is not a tty

num="20"

usage() {
    echo "Usage: `basename $0` [-nr] [-na] [-n#] [-s] [-r] [path...]" >&2
    echo >&2
    echo "    -nr    do not recurse" >&2
    echo "    -na    ignore files starting with ." >&2
    echo "    -n#    list the newest # files ($num by default)" >&2
    echo "    -r     reverse to show oldest files" >&2
    exit 1
}

num="-n$num"
dotfiles="yes"
recurse="yes"
reverse=""
while :
do
    case "$1" in
    --)        shift; break ;;
    -na)       dotfiles="no" ;;
    -nr)       recurse="no" ;;
    -n[0-9]*)  num=$1 ;;
    -r)        reverse="r" ;;
    --help)    usage ;;
    --version) echo "1.1" && exit ;;
    *)         break ;;
    esac
    shift
done
[ "$dotfiles" = "no" ] && ignore_hidden="-name '.*' -o"
[ "$recurse"  = "no" ] && dont_recurse="-maxdepth 1"
if [ $# -gt 0 ]; then
    path_format="%p"
else
    path_format="%P"
    set -- "./"
fi

ignore_metadata="\( -type d -a \( -name '.git' -o -name '.svn' -o -name 'CVS' \) \) -prune -o"
print_format="\( -type f -printf '%T@\t$path_format\n' \)"
eval find '"$@"' $dont_recurse $ignore_metadata $ignore_hidden $print_format |
sort -k1,1${reverse}n |
tail $num |
cut -f2- |
if [ ! -p /proc/self/fd/1 ]; then
    tr '\n' '\0' |
    xargs -r0 ls -lUd --color=auto --
else
    cat
fi
