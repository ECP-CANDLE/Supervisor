#!/bin/bash

if [[ ${#} != 1 ]]
then
  echo "Provide number of studies!"
  exit 1
fi
N=$1

mkdir -pv studies
IDS=$( seq -s "," 1 $N )
eval truncate -s 10K studies/study-{$IDS}.data
printf "%-7s %s\n" SIZE NAME
stat --format "%-7s %n" studies/*.data
