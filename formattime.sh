#!/bin/bash
#Script for formatting date for NODC testdata

output=$(date +%FT)
time=""

usage (){
    echo "Usage: $0 -ce"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

while getopts "ce" opt; do
    case $opt in
        #Current / created time
        c )
            time=$(date +%T)
            ;;
        #Execution time, +1 HR
        e )
            time=$(expr $(date +%H) + 1)
            if [ "$time" -eq "24" ]; then
                time="0"
            fi
            time=0$time:$(date +%M:%S)
            ;;
    esac
done
output="${output}$time"
echo $output


