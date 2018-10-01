#!/bin/bash
# Script for setting up terminal for SSH sessions

#export TERM=xterm
OLDTERM=$TERM
if [ "$TERM" = "rxvt-unicode-256color" ]; then
        TERM="rxvt-unicode"
        export TERM
        echo "Setting term to rxvt-unicode"
fi
eval $(keychain --eval --quiet --agents ssh id_rsa)>/dev/null
if [ -n "$1" ]; then
    ssh $1
    TERM=$OLDTERM
    echo Restoring term to $TERM
fi
