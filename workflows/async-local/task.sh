#!/bin/bash
set -eu

# TASK SH
# Dummy task for testing

if (( ${#} != 2 ))
then
  echo "task.sh: requires PARALLELISM PARAMS"
  exit 1
fi

WORKFLOWS=$( cd $( dirname 0 )/.. ; /bin/pwd )
source $WORKFLOWS/common/sh/utils.sh

PARALLELISM=$1
PARAMS=$2

echo "PID: $$"
# echo $PARAMS | print_json
echo

module load alps

set -x
aprun --pes $PARALLELISM bash -c 'sleep 1'
