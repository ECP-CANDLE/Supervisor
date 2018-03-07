#!/bin/bash -l
set -eu

# HIST SH
# Produces an occurrence frequency histogram for the given input file

usage()
{
  echo "usage: hist.sh DATA"
}

if [[ ${#} != 1 ]]
then
  usage
  exit 1
fi

# The user data file
DATA=$1

# Find myself
THIS=$( cd $( dirname $0 ) ; /bin/pwd )

# Strip out "Unclass", square brackets, and spaces
sed s/Unclass/,/ $DATA | tr "[]" "  " | tr -d " " | \
  awk -f $THIS/hist.awk

# | sort -n -k 2
