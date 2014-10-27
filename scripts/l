#!/bin/sh

# An enhanced and more portable ls -l

# Licence: LGPLv2
# Author:
#    http://www.pixelbeat.org/
# Notes:
#    A symlink target may lose info as there are no mode bits to highlight.
# Changes:
#    V0.1, 18 Sep 2009, Initial release
#    V0.2, 30 Sep 2009, Correctly strip "total" line for all locales
#                       Modify colors even when dircolors doesn't support $TERM
#                       Don't error for ls without --group-dir or --no-group
#    V0.3, 21 Oct 2009, Handle older ls' which pepper output with reset codes
#
#    V1.1, 05 Jun 2014
#      http://github.com/pixelb/scripts/commits/master/scripts/l

# apply thousands separator to file sizes
BLOCK_SIZE=\'1; export BLOCK_SIZE

# Traditional unix time format with abbreviated month translated from locale.
# en_* locales default to ISO format without this for reasons discussed here:
# http://lists.gnu.org/archive/html/bug-coreutils/2009-09/msg00433.html
# Note as of coreutils 8.6, `ls` will again use traditional rather than ISO
# format, unless otherwise specified by translators.
TIME_STYLE='+%b %e  %Y
%b %e %H:%M'
export TIME_STYLE

# Add a fancy symlink arrow
if echo "$LANG" | grep -i "utf-*8$" >/dev/null; then
  SYM_ARROW="▪▶"
else
  SYM_ARROW="->"
fi

ESC=`printf '\033'`

# Disable color if the current $TERM doesn't support it
if ! tput setaf 1 >/dev/null 2>&1 && ! tput AF 1 >/dev/null 2>&1; then
  color_when=
# enable highlighting if outputting to terminal or forcing
elif test -t 1 || echo "$*" | grep -E -- "--color( |=always|$)" >/dev/null; then
  # Note if the user specifies --color=auto then that will override this
  # and hence the output will not be colored :(
  color_when=always
  if tput bold >/dev/null 2>&1; then #terminfo
    BLD=`tput bold`
    RST=`tput sgr0`
    HLI=`tput smso`
  elif tput md >/dev/null 2>&1; then #termcap
    BLD=`tput md`
    RST=`tput me`
    HLI=`tput so`
  fi
  LS_HLI=`echo "$HLI" | sed "s/$ESC\[\(.*\)m/\1/"`
else
  color_when=auto
fi

ls=ls #default to standard name
{ ls --color -d . >/dev/null 2>&1; } ||
{ gls --color -d . >/dev/null 2>&1 && ls=gls; } || NONGNU=1

if [ "$color_when" ]; then
  if [ "$NONGNU" ]; then
    { colorls -d .; } >/dev/null 2>&1 && ls=colorls # for OpenBSD
    $ls -G -d . >/dev/null 2>&1 && color_opt=-G #not supported on Solaris
    [ "$color_when" = "always" ] && { CLICOLOR_FORCE=1; export CLICOLOR_FORCE; }
    color_when=

    # Turn off the confusing different background colors
    # as we'll highlight the mode bits instead. Also change the
    # main colors to match the default one on linux (coreutils).
    LSCOLORS="ExGxcxdxCxegedCxCxExEx"; export LSCOLORS
  else
    color_opt='--color='
    color_never="--color=never"
    # modify the coreutils default colors if distro or user colors not set
    [ "$LS_COLORS" ] || eval `dircolors`
    # xterm-256color not supported by older dircolors for example
    [ "$LS_COLORS" ] || eval `TERM=xterm dircolors`

    # Turn off the confusing entries with different backgrounds
    # as we'll highlight the mode bits and hardlink count instead.
    #
    # Also turn off capability colouring even though we don't
    # highlight anything in lieu of it, as this will short circuit
    # the slow capability checks within ls
    #
    # Also we reset the dangling symlink color to "highlight"
    # as it defaults to blinking.  We could do all this in ~/.dir_colors
    # but so this script is more general, we do it here.

    # Newer ls use "mh" to represent the color for multi hardlinked
    # files so handle the backwards incompatibility with "hl"
    if   dircolors | grep -F "mh=" >/dev/null; then
      hl_no_color="s/hl[^:]*:/mh=:/; s/mh[^:]*:/mh=:/"
    elif dircolors | grep -F "hl=" >/dev/null; then
      hl_no_color="s/mh[^:]*:/hl=:/; s/hl[^:]*:/hl=:/"
    fi

    # The extra quoting (wrapping in "") is required for
    # speed in bash where it inefficiently tries to glob
    # for each *.ext component of LS_COLORS, which is
    # noticeably slow in directories with many files.
    eval "`
      echo LS_COLORS=\'\"$LS_COLORS\"\'\; |

      sed \"
        $hl_no_color
        s/su[^:]*:/su=:/
        s/sg[^:]*:/sg=:/
        s/ow[^:]*:/ow=:/
        s/st[^:]*:/st=:/
        s/tw[^:]*:/tw=:/

        s/ca[^:]*:/ca=:/

        s/mi=[^:]\{1,\}:/mi=$LS_HLI:/
      \"

      echo 'export LS_COLORS'
    `"
  fi
fi
# Get locale total string to match on
total=`$ls -s $color_never / | sed 's/\([^ ]*\).*/\1/;q'`

# Use these options if available
$ls --group-directories-first -d . >/dev/null 2>&1 && gdf=--group-directories
$ls --no-group -d . >/dev/null 2>&1 && ng=--no-group

# Bypass long format manipulation if any of following formats are specified
# FIXME: Matching options like this is a bit brittle
lfmt=lfmt
echo "$*" | grep -E -- "-(m|i|x|s|C|-version|-help)" >/dev/null && lfmt=""

# Start with the standard long format listing
# with colours, and latest files at bottom
$ls -lrtq $color_opt$color_when $ng $gdf "$@" |

# process with sed to...
sed "
  # Remove total line(s) I never use
  /$total [0-9,. ]\{1,\}$/d

  # prettify symlink arrows
  s/ -> / $BLD$SYM_ARROW$RST /

  # Conditionally process long format output
  b $lfmt
  :lfmt

  # Ignore directory name headings
  /^[^ ]\{1,\}:$/b

  # temporarily shrink any prepended reset codes
  # from older ls' to a single char
  s/^$ESC\[0*m/0/

  # highlight ug+s indicators
  s/^\(0\{0,1\}.\{3\}\)\([sS]\)/\1$HLI\2$RST/
  s/^\(0\{0,1\}.\{6\}\)\([sS]\)/\1$HLI\2$RST/

  # highlight +t o+w indicators for directories
  /^0\{0,1\}d/!b not_dir
  s/^\(0\{0,1\}.\{9\}\)\([tT]\)/\1$HLI\2$RST/
  s/^\(0\{0,1\}.\{8\}\)w/\1${HLI}w$RST/
  s/^\(0\{0,1\}.\{3\}\)\([sS]\)/\1$HLI\2$RST/
  s/^\(0\{0,1\}.\{6\}\)\([sS]\)/\1$HLI\2$RST/
  :not_dir

  # highlight multiply linked files
  /^0\{0,1\}[^d]\{10,\}/!b not_hl
  /^[^ ]* *1 /b not_hl
  s/^\(0\{0,1\}[^ ]*\)\( *\)\([0-9]\{1,\}\)/\1\2$HLI\3$RST/
  :not_hl

  # restore any reset codes replaced above
  s/^0/${ESC}[0m/
"
