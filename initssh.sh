#!/bin/bash
# Script for setting up terminal for SSH sessions

oldterm=$TERM
term="default"
agent=true
addr=""
arg=""
#List of allowed arguments

usage (){
    echo "Usage: $0 [-x] host"
    exit 1
}

set_agent (){
    echo "Setting up SSH agent"
    eval $(keychain --eval --quiet --agents ssh id_rsa)>/dev/null
}

#Parse arguments
allowed="xna:t:"
while getopts $allowed opt; do
    case ${opt} in
        x )
            term=xterm
            ;;
        n )
            agent=false
            ;;

            #Pass additional arguments to SSH (ex: -a "-L 10320:localhost:3200")
            a )
            arg=$OPTARG
            ;;

            #Sets up SSH tunnel from local port X to remote target port Y
            #Usage: -t X:Y 
            t )
            lcl=$(cut -d ":" -f 1 <<< "$OPTARG")
            rmt=$(cut -d ":" -f 2 <<< "$OPTARG")
            arg="-L $lcl:localhost:$rmt"
            ;;
        \? )
            usage
            ;;
    esac
done
shift $((OPTIND -1))

if [ ! -n "$1" ]; then
    set_agent
    return 2>/dev/null
    exit
else
    addr=$1
fi
#Store and forward login credentials
if [ $agent = true ]; then
    #Set up storing of SSH authentication using keychain
    #eval $(keychain --eval --quiet --agents ssh id_rsa)>/dev/null
    set_agent
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

        ssh $arg $addr

        #Restore term var after
        TERM=$oldterm
        echo Restoring term to $TERM
        ;;
esac
