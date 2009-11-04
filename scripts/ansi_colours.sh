#!/bin/sh

# Display available ANSI (terminal) colour combinations

# Author:
#    http://www.pixelbeat.org/docs/terminal_colours/
# Changes:
#    V0.1, 24 Apr 2008, Initial release
#    V0.2, 30 Oct 2009, Support dash

e="\033["
for f in 0 7 `seq 6`; do
  no="" bo=""
  for b in n 7 0 `seq 6`; do
    co="3$f"; p="  "
    [ $b = n ] || { co="$co;4$b";p=""; }
    no="${no}${e}${co}m   ${p}${co} ${e}0m"
    bo="${bo}${e}1;${co}m ${p}1;${co} ${e}0m"
  done
  printf "$no\n$bo\n"
done
