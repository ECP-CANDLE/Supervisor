#!/bin/bash
set -eu

# TASK SH
# Dummy task for testing

if (( ${#} != 1 ))
then
  echo "Requires PARAMS!"
  exit 1
fi

WORKFLOWS=$( cd $( dirname 0 )/.. ; /bin/pwd )
source $WORKFLOWS/common/sh/utils.sh

PARAMS=$1

T=$(( $RANDOM % 3 ))

echo "PID: $$"
echo $PARAMS | print_json
echo "delay $T"
echo

sleep $T
