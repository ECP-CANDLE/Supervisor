#!/bin/bash
set -eu

# EXTRACT HOLDOUT ERRORS SH
# Extract holdout error data from all python.logs
# in given experiment directory
# Provide an experiment directory DIR
# Creates $DIR/holdout-errors.txt
# See extract-holdout-errors.awk

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

EXTRACT_HOLDOUT_ERRORS_AWK=$THIS/extract-holdout-errors.awk

NODES=$( ls $DIR/run )
for NODE in $NODES
do
  LOG=$DIR/run/$NODE/save/python.log
  awk -f $EXTRACT_HOLDOUT_ERRORS_AWK -v node=$NODE < $LOG
done > $DIR/holdout-errors.txt
