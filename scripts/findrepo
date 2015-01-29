#!/bin/sh

# find a string in the current directory and below
# while automatically ignoring repository metadata.

# Licence: LGPLv2
# Author:
#    http://www.pixelbeat.org/
# Notes:
#    One can either supply a regular expression or fixed string.
#    If just a fixed string is supplied then we specify the -F option to
#    grep so that it uses fast string matching (why doesn't it do this itself?),
#    otherwise we default to an extended regular expression.
#    The match type auto selection is disabled if a specific grep
#    match type is specified as part of the optional grep options.
# Changes:
#    V0.1, 25 Apr 2005, Initial release
#    V0.2, 25 Mar 2008, Add grep colours if available
#                       Add more repo dirs to ignore
#                       Support regular expressions not just fixed strings
#                       Support passing extra user specified options to grep
#    V0.3, 26 Mar 2008, Fix bug generating $repo_ign dirs
#    V0.4, 30 Sep 2008, Tweak grep colour to be usable on light terminals
#    V0.7, 29 Jan 2015
#      http://github.com/pixelb/scripts/commits/master/scripts/findrepo

usage() {
(
echo "Usage:    `basename $0` ['grep options'] search_expr [file wildcard]
examples: `basename $0` 'main' '*.[ch]'          #fixed string search
          `basename $0` '(main|mane)' '*.[ch]'   #regular expression search
          `basename $0` '-F' 'main(' '*.[ch]'    #force fixed string search
          `basename $0` '-L -F' 'main(' '*.[ch]' #extra grep options"
) >&2
    exit 1
}

if [ $# -eq 0 ] || [ $# -gt 3 ]; then
    usage
fi

#enable search highlighting if supported by grep
echo | grep --color=auto "" >/dev/null 2>&1 && colour="--color=auto"

if [ $# -eq 1 ]; then
    glob='*'   # common shortcut to avoid needing to specify all files
elif [ $# -eq 2 ]; then
    # if $1 begins with a '-' then we might be hitting the
    # ambiguous case where grep options are being specified,
    # so warn with info about (avoiding) the ambiguity
    if ! test "${1##-*}"; then
      echo "\
Warning: treating '$1' as the grep pattern, not extra options.
If this is intended, avoid the warning with an empty first parameter.
If this is not intended, please specify the file wildcard." >&2
    fi
    glob="$2"
elif [ $# -eq 3 ]; then
    grep_options="$1"
    shift
    glob="$2"
fi

#default to -E or -F as appropriate, not -G
if ! printf "%s\n" "$grep_options" |
     grep -E -- "-([EFGP]|regexp|fixed)" >/dev/null 2>&1; then
    #used fixed string matching for speed unless an ERE metacharacter used
    echo "$1" | grep '[.[\()*+?{|^$]' >/dev/null && type="-E" || type="-F"
    grep_options="$grep_options $type"
fi

repodirs=".git .svn CVS .hg .bzr _darcs"
for dir in $repodirs; do
    repo_ign="$repo_ign${repo_ign+" -o "}-name $dir"
done

find . \( -type d -a \( $repo_ign \)  \) -prune -o \
       \( -type f -name "$glob" -print0 \) |
#LANG=C is to work around grep multibyte inefficiencies
#GREP_COLOR="1;37;47" is bright yellow on black bg
GREP_COLOR="1;33;40" LANG=C xargs -0 grep $colour $grep_options -- "$1"
