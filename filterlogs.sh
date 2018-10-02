#!/bin/bash
#Script for filtering log inventory files. Provide path of folder containing log lists as args

if [ $# = 0 ]; then
    echo "Usage: $0 dir1 dir2 ..."
fi

dir="";

if [ ! -d filtered ]; then
    mkdir filtered
fi

#Iterate over each
while [[ $# -gt 0 ]]; do
    dir=$1;
    cd $dir
    if [ $? -ne 0 ]; then
        echo "Directory $dir not found, skipping"    
        shift
        continue
    fi
    echo 'Filtering logs in '$dir
    cat logdirs.txt | grep -E '/opt/thorax|var/log' > ../filtered/${dir}.logdirs.fltrd
    cat logfiles.txt | grep -E '/opt/thorax|var/log' > ../filtered/${dir}.logfiles.fltrd
    cd ..
    shift
done;
