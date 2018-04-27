#!/bin/bash
set -eu

# echo task.sh $*

if (( ${#} != 1 ))
then
  echo "Requires PARAMS!"
  exit 1
fi

PARAMS=$1

T=$(( $RANDOM % 3 ))

echo T=$T

sleep $T
