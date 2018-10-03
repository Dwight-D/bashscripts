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

while getopts "ca:" opt; do
    case $opt in
        #Current / created time
        c )
            time=$(date +%T)
            ;;
        #Execution time, +1 HR
        a )
            time=$(expr $(date +%H) + $OPTARG)
            if [ "$time" -ge "24" ]; then
                echo "Invalid option, next day not supported"
                exit 1
            fi
            time=0$time:$(date +%M:%S)
            ;;
    esac
done
output="${output}$time"
echo $output


