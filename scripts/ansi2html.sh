#!/bin/sh

# Convert ANSI (terminal) colours and attributes to HTML

# Licence: LGPLv2
# Author:
#    http://www.pixelbeat.org/docs/terminal_colours/
# Examples:
#    ls -l --color=always | ansi2html.sh > ls.html
#    git show --color | ansi2html.sh > last_change.html
#    Generally one can use the `script` util to capture full terminal output.
# Changes:
#    V0.1, 24 Apr 2008, Initial release
#    V0.2, 01 Jan 2009, Phil Harnish <philharnish@gmail.com>
#                         Support `git diff --color` output by
#                         matching ANSI codes that specify only
#                         bold or background colour.
#                       P@draigBrady.com
#                         Support `ls --color` output by stripping
#                         redundant leading 0s from ANSI codes.
#                         Support `grep --color=always` by stripping
#                         unhandled ANSI codes (specifically ^[[K).
#    V0.3, 20 Mar 2009, http://eexpress.blog.ubuntu.org.cn/
#                         Remove cat -v usage which mangled non ascii input.
#                         Cleanup regular expressions used.
#                         Support other attributes like reverse, ...
#                       P@draigBrady.com
#                         Correctly nest <span> tags (even across lines).
#                         Add a command line option to use a dark background.
#                         Strip more terminal control codes.
#    V0.4, 17 Sep 2009, P@draigBrady.com
#                         Handle codes with combined attributes and color.
#                         Handle isolated <bold> attributes with css.
#                         Strip more terminal control codes.
#    V0.16, 28 Mar 2014
#      http://github.com/pixelb/scripts/commits/master/scripts/ansi2html.sh

if [ "$1" = "--version" ]; then
    printf '0.16\n' && exit
fi

if [ "$1" = "--help" ]; then
    printf '%s\n' \
'This utility converts ANSI codes in data passed to stdin
It has 2 optional parameters:
   --bg=dark --palette=linux|solarized|tango|xterm
E.g.: ls -l --color=always | ansi2html.sh --bg=dark > ls.html' >&2
    exit
fi

[ "$1" = "--bg=dark" ] && { dark_bg=yes; shift; }

if [ "$1" = "--palette=solarized" ]; then
   # See http://ethanschoonover.com/solarized
   P0=073642;  P1=D30102;  P2=859900;  P3=B58900;
   P4=268BD2;  P5=D33682;  P6=2AA198;  P7=EEE8D5;
   P8=002B36;  P9=CB4B16; P10=586E75; P11=657B83;
  P12=839496; P13=6C71C4; P14=93A1A1; P15=FDF6E3;
  shift;
elif [ "$1" = "--palette=solarized-xterm" ]; then
   # Above mapped onto the xterm 256 color palette
   P0=262626;  P1=AF0000;  P2=5F8700;  P3=AF8700;
   P4=0087FF;  P5=AF005F;  P6=00AFAF;  P7=E4E4E4;
   P8=1C1C1C;  P9=D75F00; P10=585858; P11=626262;
  P12=808080; P13=5F5FAF; P14=8A8A8A; P15=FFFFD7;
  shift;
elif [ "$1" = "--palette=tango" ]; then
   # Gnome default
   P0=000000;  P1=CC0000;  P2=4E9A06;  P3=C4A000;
   P4=3465A4;  P5=75507B;  P6=06989A;  P7=D3D7CF;
   P8=555753;  P9=EF2929; P10=8AE234; P11=FCE94F;
  P12=729FCF; P13=AD7FA8; P14=34E2E2; P15=EEEEEC;
  shift;
elif [ "$1" = "--palette=xterm" ]; then
   P0=000000;  P1=CD0000;  P2=00CD00;  P3=CDCD00;
   P4=0000EE;  P5=CD00CD;  P6=00CDCD;  P7=E5E5E5;
   P8=7F7F7F;  P9=FF0000; P10=00FF00; P11=FFFF00;
  P12=5C5CFF; P13=FF00FF; P14=00FFFF; P15=FFFFFF;
  shift;
else # linux console
   P0=000000;  P1=AA0000;  P2=00AA00;  P3=AA5500;
   P4=0000AA;  P5=AA00AA;  P6=00AAAA;  P7=AAAAAA;
   P8=555555;  P9=FF5555; P10=55FF55; P11=FFFF55;
  P12=5555FF; P13=FF55FF; P14=55FFFF; P15=FFFFFF;
  [ "$1" = "--palette=linux" ] && shift
fi

[ "$1" = "--bg=dark" ] && { dark_bg=yes; shift; }

# Mac OSX's GNU sed is installed as gsed
# use e.g. homebrew 'gnu-sed' to get it
if ! sed --version >/dev/null 2>&1; then
  if gsed --version >/dev/null 2>&1; then
    alias sed=gsed
  else
    echo "Error, can't find an acceptable GNU sed." >&2
    exit 1
  fi
fi

printf '%s' "<html>
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>
<style type=\"text/css\">
.ef0,.f0 { color: #$P0; } .eb0,.b0 { background-color: #$P0; }
.ef1,.f1 { color: #$P1; } .eb1,.b1 { background-color: #$P1; }
.ef2,.f2 { color: #$P2; } .eb2,.b2 { background-color: #$P2; }
.ef3,.f3 { color: #$P3; } .eb3,.b3 { background-color: #$P3; }
.ef4,.f4 { color: #$P4; } .eb4,.b4 { background-color: #$P4; }
.ef5,.f5 { color: #$P5; } .eb5,.b5 { background-color: #$P5; }
.ef6,.f6 { color: #$P6; } .eb6,.b6 { background-color: #$P6; }
.ef7,.f7 { color: #$P7; } .eb7,.b7 { background-color: #$P7; }
.ef8, .f0 > .bold,.bold > .f0 { color: #$P8; font-weight: normal; }
.ef9, .f1 > .bold,.bold > .f1 { color: #$P9; font-weight: normal; }
.ef10,.f2 > .bold,.bold > .f2 { color: #$P10; font-weight: normal; }
.ef11,.f3 > .bold,.bold > .f3 { color: #$P11; font-weight: normal; }
.ef12,.f4 > .bold,.bold > .f4 { color: #$P12; font-weight: normal; }
.ef13,.f5 > .bold,.bold > .f5 { color: #$P13; font-weight: normal; }
.ef14,.f6 > .bold,.bold > .f6 { color: #$P14; font-weight: normal; }
.ef15,.f7 > .bold,.bold > .f7 { color: #$P15; font-weight: normal; }
.eb8  { background-color: #$P8; }
.eb9  { background-color: #$P9; }
.eb10 { background-color: #$P10; }
.eb11 { background-color: #$P11; }
.eb12 { background-color: #$P12; }
.eb13 { background-color: #$P13; }
.eb14 { background-color: #$P14; }
.eb15 { background-color: #$P15; }
"

# The default xterm 256 colour palette
for red in 0 1 2 3 4 5 ; do
  for green in 0 1 2 3 4 5 ; do
    for blue in 0 1 2 3 4 5 ; do
        c=$((16 + ($red * 36) + ($green * 6) + $blue))
        r=$((($red * 40 + 55) * ($red > 0)))
        g=$((($green * 40 + 55) * ($green > 0)))
        b=$((($blue * 40 + 55) * ($blue > 0)))
        printf ".ef%d { color: #%2.2x%2.2x%2.2x; } " $c $r $g $b
        printf ".eb%d { background-color: #%2.2x%2.2x%2.2x; }\n" $c $r $g $b
    done
  done
done
for gray in $(seq 0 23); do
  c=$(($gray+232))
  l=$(($gray*10 + 8))
  printf ".ef%d { color: #%2.2x%2.2x%2.2x; } " $c $l $l $l
  printf ".eb%d { background-color: #%2.2x%2.2x%2.2x; }\n" $c $l $l $l
done

printf '%s' '
.f9 { color: '`[ "$dark_bg" ] && printf "#$P7;" || printf "#$P0;"`' }
.b9 { background-color: #'`[ "$dark_bg" ] && printf $P0 || printf $P15`'; }
.f9 > .bold,.bold > .f9, body.f9 > pre > .bold {
  /* Bold is heavy black on white, or bright white
     depending on the default background */
  color: '`[ "$dark_bg" ] && printf "#$P15;" || printf "#$P0;"`'
  font-weight: '`[ "$dark_bg" ] && printf 'normal;' || printf 'bold;'`'
}
.reverse {
  /* CSS doesnt support swapping fg and bg colours unfortunately,
     so just hardcode something that will look OK on all backgrounds. */
  '"color: #$P0; background-color: #$P7;"'
}
.underline { text-decoration: underline; }
.line-through { text-decoration: line-through; }
.blink { text-decoration: blink; }

</style>
</head>

<body class="f9 b9">
<pre>
'

p='\x1b\['        #shortcut to match escape codes
P="\(^[^°]*\)¡$p" #expression to match prepended codes below

# Handle various xterm control sequences.
# See /usr/share/doc/xterm-*/ctlseqs.txt
sed "
# escape ampersand
s#&#\&amp;#g;
s#\x1b[^\x1b]*\x1b\\\##g  # strip anything between \e and ST
s#\x1b][0-9]*;[^\a]*\a##g # strip any OSC (xterm title etc.)

#handle carriage returns
s#^.*\r\{1,\}\([^$]\)#\1#
s#\r\$## # strip trailing \r

# strip other non SGR escape sequences
s#[\x07]##g
s#\x1b[]>=\][0-9;]*##g
s#\x1bP+.\{5\}##g
# Mark cursor positioning codes
s:β:\&#946;:g
s#${p}\([0-9]\{1,2\}\);\([0-9]\{1,2\}\)H#β\1;\2;#g

# Mark clear screen and clear to end of line
s:Ģ:\&#290;:g
s:Ω:\&#8486;:g
s#${p}K#Ģ#g
s#${p}H#Ω#g

s#${p}[0-9;?]*[^0-9;?m]##g

#remove backspace chars and what they're backspacing over
:rm_bs
s#[^Ģ\x08]\x08Ģ\{0,1\}##g; t rm_bs
" |

# Normalize the input before transformation
sed "
# escape HTML (ampersand done above)
s#>#\&gt;#g; s#<#\&lt;#g; s#\"#\&quot;#g

# normalize SGR codes a little

# split 256 colors out and mark so that they're not
# recognised by the following 'split combined' line
:e
s#${p}\([0-9;]\{1,\}\);\([34]8;5;[0-9]\{1,3\}\)m#${p}\1m${p}¬\2m#g; t e
s#${p}\([34]8;5;[0-9]\{1,3\}\)m#${p}¬\1m#g;

:c
s#${p}\([0-9]\{1,\}\);\([0-9;]\{1,\}\)m#${p}\1m${p}\2m#g; t c   # split combined
s#${p}0\([0-7]\)#${p}\1#g                                 #strip leading 0
s#${p}1m\(\(${p}[4579]m\)*\)#\1${p}1m#g                   #bold last (with clr)
s#${p}m#${p}0m#g                                          #add leading 0 to norm

# undo any 256 color marking
s#${p}¬\([34]8;5;[0-9]\{1,3\}\)m#${p}\1m#g;

# map 16 color codes to color + bold
s#${p}9\([0-7]\)m#${p}3\1m${p}1m#g;
s#${p}10\([0-7]\)m#${p}4\1m${p}1m#g;

# change 'reset' code to a single char, and prepend a single char to
# other codes so that we can easily do negative matching, as sed
# does not support look behind expressions etc.
s#°#\&deg;#g; s#${p}0m#°#g
s#¡#\&iexcl;#g; s#${p}[0-9;]*m#¡&#g
" |

# Convert SGR sequences to HTML
sed "
:ansi_to_span # replace ANSI codes with CSS classes
t ansi_to_span # hack so t commands below only apply to preceeding s cmd

/^[^¡]*°/ { b span_end } # replace 'reset code' if no preceeding code

# common combinations to minimise html (optional)
s#${P}3\([0-7]\)m¡${p}4\([0-7]\)m#\1<span class=\"f\2 b\3\">#;t span_count
s#${P}4\([0-7]\)m¡${p}3\([0-7]\)m#\1<span class=\"f\3 b\2\">#;t span_count

s#${P}1m#\1<span class=\"bold\">#;                            t span_count
s#${P}4m#\1<span class=\"underline\">#;                       t span_count
s#${P}5m#\1<span class=\"blink\">#;                           t span_count
s#${P}7m#\1<span class=\"reverse\">#;                         t span_count
s#${P}9m#\1<span class=\"line-through\">#;                    t span_count
s#${P}3\([0-9]\)m#\1<span class=\"f\2\">#;                    t span_count
s#${P}4\([0-9]\)m#\1<span class=\"b\2\">#;                    t span_count

s#${P}38;5;\([0-9]\{1,3\}\)m#\1<span class=\"ef\2\">#;        t span_count
s#${P}48;5;\([0-9]\{1,3\}\)m#\1<span class=\"eb\2\">#;        t span_count

s#${P}[0-9;]*m#\1#g; t ansi_to_span # strip unhandled codes

b # next line of input

# add a corresponding span end flag
:span_count
x; s/^/s/; x
b ansi_to_span

# replace 'reset code' with correct number of </span> tags
:span_end
x
/^s/ {
  s/^.//
  x
  s#°#</span>°#
  b span_end
}
x
s#°##
b ansi_to_span
" |

# Convert alternative character set
# Note we convert here, as if we do at start we have to worry about avoiding
# conversion of SGR codes etc., whereas doing here we only have to
# avoid conversions of stuff between &...; or <...>
#
# Note we could use sed to do this based around:
#   sed 'y/abcdefghijklmnopqrstuvwxyz{}`~/▒␉␌␍␊°±␤␋┘┐┌└┼⎺⎻─⎼⎽├┤┴┬│≤≥π£◆·/'
# However that would be very awkward as we need to only conv some input.
# The basic scheme that we do in the awk script below is:
#  1. enable transliterate once ¡ char seen
#  2. disable once µ char seen (may be on diff line to ¡)
#  3. never transliterate between &; or <> chars
sed "
# change 'smacs' and 'rmacs' to a single char so that we can easily do
# negative matching, as sed does not support look behind expressions etc.
# Note we don't use ° like above as that's part of the alternate charset.
s#\x1b(0#¡#g;
s#\x0E#¡#g;

s#µ#\&micro;#g;
s#\x1b(B#µ#g
s#\x0F#µ#g
" |
(
awk '
function dump_screen(l,c,blanks,fix,ret) {
   for(l=1;l<=maxY;l++) {
      for(c=1;c<=maxX;c++) {
         if((c SUBSEP l) in attr||length(cur)) {
             ret = ret blanks fixas(cur,attr[c,l])
             blanks=""
         }
         if((c SUBSEP l) in dump) {
             ret=ret blanks dump[c,l]
             blanks=""
         } else blanks=blanks " "

      }
      if(length(cur)) ret=ret blanks
      ret=ret "\n"
      blanks=""
   }
   return ret
}
function atos(a,i,ret) {
   for(i=1;i<=length(a);i++) ret=ret a[i]
   return ret
}
function fixas(a,s,spc,i,j,attr,use,ret) {
    spc=length(a)
    for(i=1;i<=spc;i++) {
       if(!j&&!index(s,a[i])) j=i;
       if(j) {
             ret= ret "</span>"
             delete a[i]
       }
    }
    if(j) spc=j-1
    for(i=split(s,attr,">")-1;i>0;i--) {
       attr[i]=attr[i]">"
       for(use=j=1;s&&j<=spc;j++) if(attr[i]==a[j]) use=0;
       if(use) ret=ret (a[++spc]=attr[i])
    }
    return ret
}
function encode(string,start,end,i,ret,pos,sc) {
   if(!end) end=length(string);
   if(!start) start=1;
   state=3
   for(i=1;i<=length(string);i++) {
        c=substr(string,i,1)
        if (state==2) {
            sc=sc c
            if(c==";") {
               c=sc
               state=last_mode
            } else continue
        } else {
           if(c=="<") {
		      # Change attributes - store current active
			  # attributes in span array
              split(substr(string,i),cord,">");
              i+=length(cord[1])
              if(cord[1] == "</span")
                  delete span[spc--]
              else span[++spc]=cord[1] ">"
              if(dumpStatus==dsActive) continue
              else c= cord[1] ">"
           }
           else if(c=="&") {
              sc=c
              state=2
			  continue
           }
           else if(c=="¡") {
              if(state==3) last_mode=state=4
              continue
           }
           else if(c=="µ") {
              if(state==4) last_mode=state=3
              continue
           }
           else if(c=="Ω") {
		      # Clear screen - if Recording dump screen
              delete cur
              if(dumpStatus==dsActive) ret=ret dump_screen()
              dumpStatus=dsOff
              continue
           }
           else if(c=="Ģ") {
		      # Clear to end of line. This is usually done when preparing
			  # overlay some sort of popup dialog or redraw screen.
			  # If active dump current screen contents and continue to append.
              if(dumpStatus==dsActive) {
                  delete cur
                  ret=ret dump_screen();
              }
              if(dumpStatus) {
                  for(pos=x;pos<maxX;pos++) {
                     delete dump[pos,y]
                     if (!spc) delete attr[pos,y]
                     else attr[pos,y]=atos(span)
                  }
                  dumpStatus=dsNew
              }
              continue
           }
           else if(c=="β") {
		      # Move to x,y. If we are not recording screen start now
			  # otherwise continue
              split(substr(string,i+1),cord,";");
              x=cord[2]
              y=cord[1]
			  if(y>maxY) maxY=y
              i+=length(cord[1]cord[2])+2
              dumpStatus=dumpStatus?dumpStatus:dsReset
              continue
           }
           else if(state==4&&i>=start&&i<=end&&c in N) c=N[c]
        }
        if(dumpStatus==dsReset) {
            delete dump
            delete attr
            ret=ret"\n"
            dumpStatus=dsActive
        }
        if(dumpStatus==dsNew) {
		    # After moving/clearing we are now ready to write
			# somthing to the screen so start recording now
            ret=ret"\n"
            dumpStatus=dsActive
        }
        if(dumpStatus==dsActive) {
            dump[x,y] = c
            if(!spc) delete attr[x,y]
            else attr[x,y] = atos(span)
            if(++x>maxX) maxX=x;
        }
        else ret=ret c
    }
	# End of line if dumping increment y and set x back to first col
    if(dumpStatus==dsActive) {x=1; if(++y>maxY) maxY=y; }
    return ret
}
BEGIN{
    OFS=FS
	# dump screen status
	dsOff=0    # Not dumping screen contents just write output direct
	dsNew=1    # Just after move/clear waiting for activity to start recording
	dsReset=2  # Screen cleared build new empty buffer and record
	dsActive=3 # Currently recording
    F="abcdefghijklmnopqrstuvwxyz{}`~"
    T="▒␉␌␍␊°±␤␋┘┐┌└┼⎺⎻─⎼⎽├┤┴┬│≤≥π£◆·"
    for(i=1;i<=length(F);i++)N[substr(F,i,1)]=substr(T,i,1);
}

{ $0=encode($0) } 1 '
# sed -e 's/[ĢΩ¡µ]//g' -e 's/β[^;]*;[^;]*;//g' # just strip alternative flag chars
)

printf '</pre>
</body>
</html>\n'
