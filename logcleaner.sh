#!/bin/bash
#Author: Max Forsman, max.forsman@tieto.com

#Script for cleaning up logs
#Function:
#Goes through a list of directories and searches for log files (.out, .log) over a 
#certain age. Deletes old log files and outputs a list of unrecognized old files to stderr

#Instructions:
#Call script with argument pointing to a file with a list of all folders you want to check, ex
#"/opt/app/somelogs
#/opt/sys/otherlogs
#/app/etc..."

#TODO: 
#Add support for different file formats
#Add ignore list


base=$(readlink -f $(dirname $BASH_SOURCE))
logrot=logrotate.conf
debug=false
maxage=14

usage (){
	echo "$(basename $0): Utility script for cleaning up old logfiles, ending with .log or .out"
	echo ""
	echo "Usage: $(basename $0): [-d] [-a X] list.txt"
	echo "Where list.txt points to a file with a list of all folders you want to clean"
	echo -e "\t-d	Debug, don't delete files, just print output"
	echo -e "\t-a X	Max age = X days (default=14), delete all files over this age"
	exit 1
}


while getopts "da:" opt; do
	case $opt in
		d )
			echo "Debug mode enabled, no files will be deleted"
			debug=true
			;;
		a )
			maxage=$OPTARG
			;;
		? )
			usage
			;;
		: )
			echo "Option requires an argument: $OPTARG"
			exit 1
			;;
	esac
done
shift $((OPTIND -1))
if [ $# != 1 ]; then
	usage
fi
dirty=$1
if [ ! -r "$dirty" ]; then
	echo "Error reading file, exiting: $dirty" 1>&2
	return 1 &>/dev/null
	exit 1
fi

while read -r dir; do
	if [ ! -d $dir ]; then
		echo -e "Not a directory, skipping: $dir" 1>&2
		continue
	fi
	#Check if string begins with /
	if [ "${dir:0:1}" != '/' ]; then
		echo -e "Not an absolute path, unsafe, skipping: $dir" 1>&2
		continue
	fi
	echo "Cleaning up $dir"

	#Find files older than maxage
	old=$(find "$dir" -mtime +${maxage} -type f)

	#Look for files ending with .out or .log
	hitlist=$(grep -E "*\.(log|out)" <<< "$old")
	
	echo "Removing: "
	echo "$hitlist"
	if [ "$debug" = false ]; then
		xargs rm <<< "$hitlist"
	fi
	
	echo "Unrecognized files: " 1>&2
	grep -E -v "*\.(log|out)" <<< "$old" 1>&2

done < $dirty
