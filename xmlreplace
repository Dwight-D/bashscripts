#!/bin/bash
#Script for replacing the content of an xml-tag
#Reads from stdin if no file is provided

tag=""
content=""
file=""
str=""
output=""

usage (){
    echo "Usage: $0 tag content [file]"
    exit 1
}

tag=$1
content=$2
file=$3

if [ $# -lt 2 ]; then
    usage
fi
#Set IFS to avoid consuming whitespace
IFS=
while read line
do
    str=$(sed "s/<${tag}>.*${tag}>/<${tag}>$content<\/${tag}>/" <<<$line)
    echo $str 

#Reads from file if defined, otherwise redireects to stdin
done < "${file:-/dev/stdin}"
