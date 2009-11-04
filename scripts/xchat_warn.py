#!/bin/false

# An xchat plug to warn when someone references you directly

# put this in ~/.xchat2/ dir to autoload
# Note this requires that xchat-python is installed

__module_name__ = "xchat_warn"
__module_version__ = "1.0"
__module_description__ = "Warn when someone is referencing you directly"

import time
import os
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
    to = to.lower()
    if to==nick or message.lower().find(nick)>=0:
        if now-lastAlert > 10: #10s at least since referenced
            Alert(message)
        lastAlert=now
    return xchat.EAT_NONE

def ServerMessagePRIVMSG(word, word_eol, userdata):
    CheckAlert(word[2],word_eol[3][1:])
    return xchat.EAT_NONE

xchat.hook_server("PRIVMSG", ServerMessagePRIVMSG)

print "pixelbeat's xchat notifier loaded"
