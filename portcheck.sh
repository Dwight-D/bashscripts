#!/bin/bash
#Author: Max Forsman

#Script for checking port connectivity. Provide CSV in format COMMENT;ALIAS;IP;PORT...;PORT
#Results output as csv
#Depends on netcat, openbsd-netcat package recommended
#NB: Avoid usage of semicolons in input csv (obviously)

timeout=3
tmp_file='tmp.txt'
output_file='results.csv'
method="ip"

usage (){
    echo ""
    echo "$(basename $0):"
    echo "Utility script for checking port connectivity"
    echo "Output saved in results.csv"
    echo ""
    echo "Usage:"
    echo "$(basename $0) [-i] [-a] [-t X] path"
    echo "where 'path' leads to a csv file in the format"
    echo " \"name ; alias ; ip ; port [; port ; ... ; port]\" "
    echo ""
    echo "Options:"
    echo -e "\t -h      Display help"
    echo -e "\t -i      Set connection method to IP"
    echo -e "\t -a      Set connection method to alias/DNS-name"
    echo -e "\t -t X    Set timeout to X seconds"
    exit 1
}

check_port(){
    nc -zv -w $timeout $1 $2
    return $?
}


check_all_ports(){
    #set delimiter
    IFS=';'
    #split into comment alias ip and ports
    while read comment alias ip portstr; do
        #split ports by space into array
        if [ $(wc -w <<< $ip ) -gt 0 ]
        then
            #read ports into array and iterate
            read -ra ports <<< $portstr
            for port in "${ports[@]}"; do
                #check if port contains a word, else string is garbage
                if [ $(wc -w <<< $port ) -gt 0 ]; then
                    echo -n $comment';i'$alias';'$ip';'$port';' >> $output_file
                    case $method in
                        ip )
                            check_port $ip $port
                            ;;
                        alias )
                            check_port $alias $port
                            ;;
                    esac

          #check port connectivity and write results
          if (( $? == 0 )); then
              echo yes >> $output_file
          else
              echo no >> $output_file
          fi
      fi
  done
fi
#use input from temp file in read func
done < $tmp_file
}

#Script begin
#=================================================

echo $@
while getopts "iat:" opt; do
    case  $opt in
        i )
            method="ip"
            ;;
        a )
            method="alias"
            ;;
        t )
            timeout="$OPTARG"
            ;;
        h )
            usage
            ;;

        \? )
            echo "Invalid option: $OPTARG"
            usage
            ;;

    esac
done
shift $((OPTIND-1))

input_file=$1

if [ ! -f "$input_file" ];then 
    echo "Error reading or no input file specified "$input_file
    usage
fi    

#trim windows-style newlines into temp working file
cat $input_file | tr -d '\r' > $tmp_file

#Set column descriptors
echo 'COMMENT;ALIAS;IP;PORT;REACHABLE?' > $output_file
echo Checking ports
echo Connection method: $method
echo Timeout: $timeout

check_all_ports

#delete temp file after
rm $tmp_file
exit 0
