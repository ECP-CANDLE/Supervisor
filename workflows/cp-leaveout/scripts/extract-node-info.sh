#!/bin/bash
set -eu

# EXTRACT NODE INFO SH
# Extract all data from all logs in given experiment directory
# Provide an experiment directory DIR
# Creates $DIR/node-info.pkl

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

if [[ ! -d $DIR ]]
then
  echo "$0: Given experiment directory does not exist: $DIR"
  exit 1
fi

# Put all matching file names in this file, one per line
# (this could contain thousands of entries, too long for command line):
LOG_LIST=$DIR/log-list.txt

shopt -s nullglob  # Ignore empty globs
RESTARTS=( $DIR/restarts/* )

for RESTART in ${RESTARTS[@]}
do
  $SUPERVISOR/scripts/shrink-logs.sh $RESTART/out
done
$SUPERVISOR/scripts/shrink-logs.sh $DIR

{
  for RESTART in ${RESTARTS[@]}
  do
    echo $RESTART/out/summary-*.txt
  done
  echo $DIR/out/summary-*.txt
} | fmt -w 1 > $LOG_LIST

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

set -x
python3 -u $THIS/extract-node-info.py $DIR
