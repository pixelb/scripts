#!/bin/false

# An xchat plugin to warn when someone references you directly

# Author:
#    http://www.pixelbeat.org/
# Notes:
#    Put this in ~/.xchat2/ dir to autoload.
#    This plugin requires that xchat-python is installed
# Changes:
#    V1.0, 02 Dec 2005, Initial release
#    V2.0, 04 Nov 2009
#      http://github.com/pixelb/scripts/commits/master/scripts/xchat_warn.py


__module_name__ = "xchat_warn"
__module_version__ = "2.0"
__module_description__ = "Warn when someone is referencing you directly"

import time
import os
import re
import xchat
lastAlert=0

def Alert(message):
    message=message.replace("'","`") #make safe for shell
    #Other options to display message are gdialog, gxmessage
    os.system("xmessage -nearmouse -default okay '%s' &" % message)
#    os.system("zenity --info --title='xchat' --text='%s' &" % message)
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
