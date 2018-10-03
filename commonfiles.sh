#!/bin/bash
#Script for comparing the file permissions of two different systems
#Input is output of "ls -l" of respective folders


file1=$1
file2=$2
out1=$1.out
out2=$2.out

common="common.txt"

if [ $# -ne 2 ]; then
    echo "Usage: $0 list1 list2"
fi
#Cut filename from list of files, substitute into comm, suppress 
#unique colums, add to common files
comm -12 \
    <(tr -s ' ' <$file1 | cut -f "9" -d " " | sort) \
    <(tr -s ' ' <$file2 | cut -f "9" -d " " | sort)\
    >$common

grep -f $common $file1 | tr -s ' ' | cut -f "1,3,4,9" -d " " >$out1

grep -f $common $file2 | tr -s ' ' | cut -f "1,3,4,9" -d " " >$out2

echo $out1 $out2
