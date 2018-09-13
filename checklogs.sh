#!/bin/bash

#Script for checking the log files on the machine
#Outputs a list of log files (.log and .out) in descending border
#as well as a list of all directories containing log files
logs=logfiles.txt
dirs=logdirs.txt

echo "Checking logs..."

sudo find / -type f \( -name \*.log -o -name \*.out \) | sudo xargs du -h | sort -rh > $logs
cat $logs | cut -f2 | xargs -n 1 dirname | uniq | xargs sudo du -h | sort -rh | uniq > $dirs

echo "Log files: "$logs
echo "Log directories: "$dirs

# sudo find / -type f \( -name \*.log -o -name \*.out \) | sudo xargs du -h | sort -rh | cut -f2 | xargs -n 1 dirname | uniq | xargs sudo du -h | sort -rh | uniq > logdirs.txt
