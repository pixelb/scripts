#!/bin/sh

# Display available ANSI (terminal) colour combinations

# License: LGPLv2
# Author:
#    http://www.pixelbeat.org/docs/terminal_colours/
# Changes:
#    V0.1, 24 Apr 2008, Initial release
#    V0.2, 30 Oct 2009, Support dash
#    V0.4, 17 May 2011
#      http://github.com/pixelb/scripts/commits/master/scripts/ansi_colours.sh

e="\033["
vline=$(tput smacs 2>/dev/null; printf 'x'; tput rmacs 2>/dev/null)
[ "$vline" = "x" ] && vline="|"

#printf "${e}4m%80s${e}0m\n"
printf "${e}1;4mf\\\\b${e}0m${e}4m none  white    black     red     \
green    yellow   blue    magenta    cyan  ${e}0m\\n"

rows='brgybmcw'

for f in 0 7 `seq 6`; do
  no=""; bo=""; p=""
  for b in n 7 0 `seq 6`; do
    co="3$f"; [ $b = n ] || co="$co;4$b"
    no="${no}${e}${co}m  ${p}${co} ${e}0m"
    bo="${bo}${e}1;${co}m${p}1;${co} ${e}0m"
    p=" "
  done
  fc=$(echo $rows | cut -c$((f+1)))
  printf "$fc $vline$no\nb$fc$vline$bo\n"
done
