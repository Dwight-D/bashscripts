#!/bin/bash
#Script for filtering log inventory files.

dir="";
mkdir filtered
while [[ $# -gt 0 ]]; do
  dir=$1;
  cd $dir
  echo 'Filtering logs in '$dir
  cat logdirs.txt | grep -E '/opt/thorax|var/log' > ../filtered/${dir}.logdirs.fltrd
  cat logfiles.txt | grep -E '/opt/thorax|var/log' > ../filtered/${dir}.logfiles.fltrd
  cd ..
  shift
done;
