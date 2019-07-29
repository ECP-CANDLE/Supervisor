#!/bin/bash
set -eu

# EXTRACT LOSS SH
# Extract losses
# Provide a directory full of model.logs

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

# The stdout from the workflow (read by this script)
OUTPUT=$DIR/output.txt
# The output of this script, a plottable file
LOSSES=$DIR/losses.txt

RUNS=$( ls $DIR/run )

for RUN in $RUNS
do
  # grep "val_loss: " $DIR/run/$RUN/model.log | tail -1
  printf "%-10s " $RUN
  sed '/val_loss:/ {s/result: val_loss: \(.*\)/\1/ ; h}; $!d; x' \
      $DIR/run/$RUN/model.log
done > $LOSSES


# # Make the summary
# python3 $SUPERVISOR/scratch/load/load.py \
#  "$DATE_START" "$DATE_STOP" < $T > $SUMMARY
# set -x
# # python3 $SUPERVISOR/scratch/load/load.py \
# #        "$DATE_START":00 "$DATE_STOP":00 < $T > $SUMMARY
# # rm $T

echo "extract-loss.sh: wrote: $LOSSES"
