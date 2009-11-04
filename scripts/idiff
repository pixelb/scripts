#!/bin/sh

# Color diff output, for human consumption

# Author:
#    http://www.pixelbeat.org/
# Notes:
#    If 2 parameters are passed, then they are passed to
#    the `diff -Naru` command first. Otherwise the parameters
#    (or stdin) are assumed to be diff format and are colourised.
#
#    VIM can be useful for viewing diffs also:
#      diff -Naru a b | vim -R -
#      vim -R a-b.diff
# Changes:
#    V0.1, 12 Feb 2008, Initial release
#    V0.2, 18 Feb 2008, Use tput rather than hardcoding escape sequences.
#    V0.3, 24 Apr 2008, Support Mac OS X
#    V0.4, 30 Apr 2008, P@draigBrady.com
#                         Use $PAGER if set
#                       Manfred Schwarb <manfred99@gmx.ch>
#                         Support `diff -c` format fully.
#                         Pointed out issues with less -EF options.
#                         Suggested to use the less -S option.
#    V0.5, 18 Jun 2009, P@draigBrady.com
#                         Delineate each file level item with highlight.
#                         Simplify expressions by using '&' in replacement.
#                         Use 't' after all matches for consistency and speed.

# less -K reportedly not available on older Mac OS X
less -K -Ff /dev/null 2>/dev/null && CTRL_C_EXITS="-K"

RED=1; GREEN=2; BLUE=4; BRIGHT='1;'

tputc() {
    bright=$1; colour=$2
    [ "$bright" ] && tput bold
    tput setaf $colour
}

DEL="`tputc $BRIGHT $RED`"
ADD="`tputc $BRIGHT $GREEN`"
CHG="`tputc $BRIGHT $BLUE`"
FIL="`tput smso`" #highlight file level items
RST="`tput sgr0`"

if [ "$#" -eq "2" ]; then
    diff -Naru "$@"
else
    cat "$@"
fi |
sed "
s/^\*\{3\}.*\*\{4\}/$CHG&$RST/;t
  s/^-\{3\}.*-\{4\}/$CHG&$RST/;t
             s/^@.*/$CHG&$RST/;t
         s/^[0-9].*/$CHG&$RST/;t
             s/^!.*/$CHG&$RST/;t

             s/^-.*/$DEL&$RST/;t
             s/^<.*/$DEL&$RST/;t

            s/^\*.*/$ADD&$RST/;t
            s/^\+.*/$ADD&$RST/;t
             s/^>.*/$ADD&$RST/;t

       s/^Only in.*/$FIL&$RST/;t
       s/^Index: .*/$FIL&$RST/;t
         s/^diff .*/$FIL&$RST/;t
" |
${PAGER:-less -QRS $CTRL_C_EXITS}

# could use less -EFX also, but for large files or lots of scrolling, this
# is a lot more obtrusive on the terminal as the [de]init codes not used.
