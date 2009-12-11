#!/bin/sh

# Convert ANSI (terminal) colours and attributes to HTML

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
#    V0.5, 27 Nov 2009, Mark Harviston <harvimt@pdx.edu>
#                         Handle backspace characters, carriage returns and
#                         terminal hardstatus to better handle typescripts.
#                         Also be explicit about, and support the control codes
#                         for, default foreground and background colors.
#    V0.6, 07 Dec 2009, P@draigBrady.com
#                         Support 256 colour xterm codes.
#    V0.7, 11 Dec 2009, P@draigBrady.com
#                         Support 16 color xterm codes.

if [ "$1" = "--version" ]; then
    echo "0.7" && exit
fi

if [ "$1" = "--help" ]; then
    echo "This utility converts ANSI codes in data passed to stdin" >&2
    echo "It has 1 optional parameter: --bg=dark" >&2
    echo "E.g.: ls -l --color=always | ansi2html.sh --bg=dark > ls.html" >&2
    exit
fi

[ "$1" = "--bg=dark" ] && dark_bg=yes

echo -n '<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<style type="text/css">
/* linux console palette */
.ef0,.f0 { color: #000000; } .eb0,.b0 { background-color: #000000; }
.ef1,.f1 { color: #AA0000; } .eb1,.b1 { background-color: #AA0000; }
.ef2,.f2 { color: #00AA00; } .eb2,.b2 { background-color: #00AA00; }
.ef3,.f3 { color: #AA5500; } .eb3,.b3 { background-color: #AA5500; }
.ef4,.f4 { color: #0000AA; } .eb4,.b4 { background-color: #0000AA; }
.ef5,.f5 { color: #AA00AA; } .eb5,.b5 { background-color: #AA00AA; }
.ef6,.f6 { color: #00AAAA; } .eb6,.b6 { background-color: #00AAAA; }
.ef7,.f7 { color: #AAAAAA; } .eb7,.b7 { background-color: #AAAAAA; }
.ef8, .f0 > .bold,.bold > .f0 { color: #555555; font-weight: normal; }
.ef9, .f1 > .bold,.bold > .f1 { color: #FF5555; font-weight: normal; }
.ef10,.f2 > .bold,.bold > .f2 { color: #55FF55; font-weight: normal; }
.ef11,.f3 > .bold,.bold > .f3 { color: #FFFF55; font-weight: normal; }
.ef12,.f4 > .bold,.bold > .f4 { color: #5555FF; font-weight: normal; }
.ef13,.f5 > .bold,.bold > .f5 { color: #FF55FF; font-weight: normal; }
.ef14,.f6 > .bold,.bold > .f6 { color: #55FFFF; font-weight: normal; }
.ef15,.f7 > .bold,.bold > .f7 { color: #FFFFFF; font-weight: normal; }
.eb8  { background-color: #555555; }
.eb9  { background-color: #FF5555; }
.eb10 { background-color: #55FF55; }
.eb11 { background-color: #FFFF55; }
.eb12 { background-color: #5555FF; }
.eb13 { background-color: #FF55FF; }
.eb14 { background-color: #55FFFF; }
.eb15 { background-color: #FFFFFF; }
'

# The default xterm 256 colour palette
for red in $(seq 0 5); do
  for green in $(seq 0 5); do
    for blue in $(seq 0 5); do
        c=$((16 + ($red * 36) + ($green * 6) + $blue))
        r=$((($red ? ($red * 40 + 55) : 0)))
        g=$((($green ? ($green * 40 + 55) : 0)))
        b=$((($blue ? ($blue * 40 + 55) : 0)))
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

echo -n '
.f9 { color: '`[ "$dark_bg" ] && echo '#AAAAAA;' || echo '#000000;'`' }
.b9 { background-color: #'`[ "$dark_bg" ] && echo '000000' || echo 'FFFFFF'`'; }
.f9 > .bold,.bold > .f9, body.f9 > pre > .bold {
  /* Bold is heavy black on white, or bright white
     depending on the default background */
  color: '`[ "$dark_bg" ] && echo '#FFFFFF;' || echo '#000000;'`'
  font-weight: '`[ "$dark_bg" ] && echo 'normal;' || echo 'bold;'`'
}
.reverse {
  /* CSS doesnt support swapping fg and bg colours unfortunately,
     so just hardcode something that will look OK on all backgrounds. */
  color: #000000; background-color: #AAAAAA;
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
s#\x1b[^\x1b]*\x1b\\\##g  # strip anything between \e and ST
s#\x1b][0-9]*;[^\a]*\a##g # strip any OSC (xterm title etc.)

#handle carriage returns
s#^.*\r\{1,\}\([^$]\)#\1#
s#\r\$## # strip trailing \r

# strip other non SGR escape sequences
s#[\x07]##g
s#\x1b[]>=\][0-9;]*##g
s#\x1bP+.\{5\}##g
s#\x1b(B##g
s#${p}[0-9;?]*[^0-9;?m]##g

#remove backspace chars and what they're backspacing over
:rm_bs
s#[^\x08]\x08##g; t rm_bs
" |

# Normalize the input before transformation
sed "
# escape HTML
s#\&#\&amp;#g; s#>#\&gt;#g; s#<#\&lt;#g; s#\"#\&quot;#g

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
"
echo "</pre>
</body>
</html>"
