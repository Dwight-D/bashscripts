#!/bin/bash
# Script for setting up terminal for SSH sessions

__OLDTERM=$TERM
#Change to more recognizeable terminal
if [ "$TERM" = "rxvt-unicode-256color" ]; then
        TERM="rxvt-unicode"
        export TERM
        echo "Setting term to rxvt-unicode"
fi
#Set up storing of SSH authentication using keychain
eval $(keychain --eval --quiet --agents ssh id_rsa)>/dev/null
#If argument supplied, connect directly over ssh and reset term after session
if [ -n "$1" ]; then
    #If connecting to TVAS, change to server-compliant terminal and disconnect subprocess
    if [[ "$1" = "tvas"* ]]; then
        nohup xterm -e ssh $1 &
    else
        ssh $1
    fi
    TERM=$__OLDTERM
    echo Restoring term to $TERM
fi
