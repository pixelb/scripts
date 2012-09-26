#!/bin/sh

# This script is a template for a self modifiying script

# License: LGPLv2

# Change the following to whatever
# method updates your script, for e.g.
#     svn update $0
update_method() {
    return
}
# Note the exec must be read from disk
# before updated_method is called, hence
# why update_this_script is in a function.
update_this_script() {
    old_md5=`md5sum $0 | cut -d' ' -f1`
    update_method
    new_md5=`md5sum $0 | cut -d' ' -f1`
    if [ "$old_md5" != "$new_md5" ]; then
        exec $0 "$@"
    fi
}
update_this_script

echo "rest of script here"
