#!/bin/bash
set -eu

# EXTRACT NODE INFO SH
# Extract all data from all logs in given experiment directory
# Provide an experiment directory

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


# # The stdout from the workflow (read by this script)
# OUTPUT=$DIR/output.txt
# # The output of this script, a plottable file
# SUMMARY=$DIR/summary.txt

# Put all matching file names in this file, one per line
# (this could contain thousands of entries, too long for command line):
LOG_LIST=$DIR/log-list.txt

RESTARTS=( $DIR/restarts/* )

shopt -s nullglob # Ignore empty globs
{
  for RESTART in ${RESTARTS[@]}
  do
    echo $RESTART/out/out-*.txt
  done
  echo $DIR/out/out-*.txt
} | fmt -w 1 > $LOG_LIST

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

set -x
python3 -u $THIS/extract-node-info.py $DIR
