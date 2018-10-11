#!/bin/bash
#Author: Max Forsman, max.forsman@tieto.com

#Script for cleaning up old files
#Function:
#Goes through a list of directories and searches for files with certain extensions over a
#certain age. Deletes old files and outputs a list of unrecognized files to stderr

#Instructions:
#Call script with argument pointing to a file with a list of all folders you want to check, ex
#"/opt/app/somelogs
#/opt/sys/otherlogs
#/app/etc..."

#TODO: 
#Add ignore list


base=$(readlink -f $(dirname $BASH_SOURCE))
debug=false
maxage=14
extensions=()
regexp=""

usage (){
    echo "$(basename $0): Utility script for cleaning up old files with matching extensions"
    echo "Typical use case: remove log files over a certain age"
    echo ""
    echo "Usage: $(basename $0): [-d] [-a X] [-e ext] list.txt"
    echo "Where list.txt points to a file with a list of all folders you want to clean"
    echo ""
    echo "Options:"
    echo -e "\t-d\tDebug, don't delete files, just print output"
    echo -e "\t-a X\tMax age = X days (default=14), delete all files over this age"
    echo -e "\t-e ext\tOverrides default file extensions (.log, .err, .out) and instead looks for .ext (do not include dot in arg)."
    echo -e "\tCan be used multiple times, eg. \"-e log -e out - err\""

    exit 1
}


#Prepare regex searching for file extensions
prep_regex (){
    regexp="*\.("
    for ext in "${extensions[@]}"; do
        regexp+="${ext}|"
    done
    regexp+=")$"
    regexp=${regexp//|)/)}
}

#Parse args
while getopts "dha:e:" opt; do
    case $opt in
        d )
            debug=true
            ;;
        a )
            maxage=$OPTARG
            ;;
        e )
            extensions+=("$OPTARG")
            ;;
        h )
            usage
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

#If no extensions have been provided, set to defaults
if [ ${#extensions[@]} -eq 0 ]; then
    extensions=( 'log' 'out' 'err' )
fi

prep_regex

if [ "$debug" = true ]; then
    echo "Debug mode enabled, no files will be deleted"
fi

echo -n "Deleting files with extensions: "
for str in "${extensions[@]}"; do
    echo -n ".$str "
done
echo ""

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
    echo ""
    echo "Cleaning up $dir"

    #Find files older than maxage
    old=$(find "$dir" -mtime +${maxage} -type f)

    #Look for files with provided extensions
    hitlist=$(grep -E "$regexp" <<< "$old")
    if [ ! -z "$hitlist" ]; then
        echo "Removing: "
    fi
    echo "$hitlist"
    if [ "$debug" = false ]; then
        xargs rm <<< "$hitlist"
    fi

    echo "Unrecognized files: " 1>&2
    grep -E -v "$regexp" <<< "$old" 1>&2

done < $dirty
