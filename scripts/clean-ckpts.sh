#!/bin/bash
set -eu

# CLEAN CKPTS SH

# Clean up old checkpoints in DIR
# Retains at least KEEP checkpoints

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide DIR (e.g., .../experiments/X042) and KEEP" \
          DIR KEEP - ${*}

if [[ ! -d $DIR ]]
then
  echo "$0: Given experiment directory does not exist: $DIR"
  exit 1
fi

RUNS=( $( echo $DIR/run/* ) )

for RUN in ${RUNS[@]}
do
  $THIS/clean-ckpts-run.sh $RUN $KEEP
  echo
done
