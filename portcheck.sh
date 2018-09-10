#!/bin/bash

timeout=1
input_file=$1
tmp_file='tmp.txt'
#delimiter must be set inside loops as well if want to change
delim=';'
output_file='results.txt'

test_func(){
  echo $1 $2
}

check_port(){
  nc -zv -w $timeout $1 $2
  return $?
}

check_all_ports(){
  #set delimiter

  IFS=$delim
  #split into ip and ports
  while read ip portstr; do
    #split ports by space into array
    if [ $(wc -w <<< $ip ) -gt 0 ]
    then
      read -ra ports <<< $portstr
      #iterate over ports array
      for port in "${ports[@]}"; do
        #check if i contains a word

        if [ $(wc -w <<< $port ) -gt 0 ]; then
          echo -n $ip';'$port';' >> $output_file
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

if [ ! -f "$input_file" ]
  then echo "Error reading file "$input_file
else
  #trim windows-style newlines
  cat $input_file | tr -d '\r' > $tmp_file
  echo IP${delim}PORT${delim}REACHABLE? > $output_file
  check_all_ports
  #delete temp file after
  rm $tmp_file
fi

#var1=$1
#var2=$2
#check_ports $var1 $var2
#output=$?
#exit $output
