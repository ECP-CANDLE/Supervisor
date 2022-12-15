#!/bin/sh

# CLEAN CKPTS SH

# Clean up old checkpoints

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

RUNS=( $( echo $DIR/run/* ) )

for RUN in ${RUNS[@]}
do
  set -x
  $THIS/clean-ckpts-run.sh $RUN
done
