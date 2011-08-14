#!/bin/false

# An xchat plugin to warn when someone references you directly

# Author:
#    http://www.pixelbeat.org/
# Notes:
#    Put this in ~/.xchat2/ dir to autoload.
#    This plugin requires that xchat-python is installed
# Changes:
#    V1.0, 02 Dec 2005, Initial release
#    V2.1, 14 Aug 2011,
#      http://github.com/pixelb/scripts/commits/master/scripts/xchat_warn.py


__module_name__ = "xchat_warn"
__module_version__ = "2.1"
__module_description__ = "Warn when someone is referencing you directly"

import time
import os
import re
import xchat
import pipes
lastAlert=0

def Alert(message):
    arg = pipes.quote("--text=xchat: %s" % message) #make safe for shell
    #Other options to display message are gdialog, gxmessage
    os.system("zenity --timeout=1 --notification %s &" % arg)
#    os.system("xmessage -nearmouse -default okay %s &" % arg)
#    os.system("play /usr/share/sounds/gtk-events/clicked.wav")

def CheckAlert(to,message):
    global lastAlert
    now=int(time.time())
    nick = xchat.get_info("nick")
    nick = nick.lower()
    match = re.search(r'\b(%s)\b' % re.escape(nick), message, re.IGNORECASE)
    to = to.lower()
    if to==nick or match:
        if now-lastAlert > 10: #10s at least since referenced
            Alert(message)
        lastAlert=now
    return xchat.EAT_NONE

def ServerMessagePRIVMSG(word, word_eol, userdata):
    CheckAlert(word[2],word_eol[3][1:])
    return xchat.EAT_NONE

xchat.hook_server("PRIVMSG", ServerMessagePRIVMSG)

print "pixelbeat's xchat notifier loaded"
