#!/bin/bash
set -eu

# BASELINE ERROR LIST SH
# WIP: Script to extract python.logs from a given DIR and STAGE

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          -H "and OUTPUT filename" \
          DIR STAGE OUTPUT - ${*}

if [[ ! -d $DIR ]]
then
  echo "$0: Given experiment directory does not exist: $DIR"
  exit 1
fi

for F in experiments/X385/run/?.?.?.?.?.?/save/python.log
do
  echo $( basename $( dirname $( dirname $F ) ) )
done > $OUTPUT
