#!/bin/bash
# Script for setting up terminal for SSH sessions

oldterm=$TERM
term="default"
agent=true
addr=""

usage (){
    echo "Usage: $0 [-x] host"
    exit 1
}

args (){

    #Parse arguments
    local OPTIND xn opt
    while getopts ":xn" opt; do
        case ${opt} in
            x )
                term=xterm
                ;;
            n )
                agent=false
                ;;
            \? )
                usage
                ;;
        esac
        shift $((OPTIND -1))
    done
    #If no host arg supplied
    if [ ! -n "$1" ]; then
        usage
    else
        addr=$1
    fi
}

args "$@"

#Store and forward login credentials
if [ $agent = true ]; then
    #Set up storing of SSH authentication using keychain
    eval $(keychain --eval --quiet --agents ssh id_rsa)>/dev/null
fi
echo "Attempting to connect to $addr over terminal $term"

case ${term} in
    xterm )
        nohup xterm -e ssh -a $addr &>/dev/null &
        ;;
    default )
        #Change to more recognizeable terminal
        if [ "$TERM" = "rxvt-unicode-256color" ]; then
            TERM="rxvt-unicode"
            export TERM
            echo "Setting term to rxvt-unicode"
        fi
        
        ssh $addr

        #Restore term var after
        TERM=$oldterm
        echo Restoring term to $TERM
        ;;
esac
