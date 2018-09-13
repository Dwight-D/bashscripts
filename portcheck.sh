#!/bin/bash
#Script for checking port connectivity. Provide CSV in format IP;PORT...
#Results output as csv
#Depends on netcat, openbsd-netcat package recommended

timeout=3
input_file=$1
tmp_file='tmp.txt'
output_file='results.txt'

check_port(){
  nc -zv -w $timeout $1 $2
  return $?
}

check_all_ports(){
  #set delimiter
  IFS=';'
  #split into ip and ports
  while read ip portstr; do
    #split ports by space into array
    if [ $(wc -w <<< $ip ) -gt 0 ]
    then
      #read ports into array and iterate
      read -ra ports <<< $portstr
      for port in "${ports[@]}"; do
        #check if port contains a word, else string is garbage
        if [ $(wc -w <<< $port ) -gt 0 ]; then
          echo -n $ip';'$port';' >> $output_file
          #check port connectivity and write results
          check_port $ip $port
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

if (( $# != 1 )); then
  echo "Usage: portcheck INPUT_FILE"
  exit 1
elif [ ! -f "$input_file" ]
  then echo "Error reading file "$input_file
  exit 1
else
  #trim windows-style newlines into temp working file
  cat $input_file | tr -d '\r' > $tmp_file
  #Set column descriptors
  echo 'IP;PORT;REACHABLE?' > $output_file
  check_all_ports
  #delete temp file after
  rm $tmp_file
fi
exit 0
