#!/bin/bash
set -eu

# EXTRACT TIME SH
# Extract final times
# Provide a directory full of model.logs

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

# The stdout from the workflow (read by this script)
OUTPUT=$DIR/output.txt
# The output of this script
TIMES=$DIR/times.txt

RUNS=$( ls $DIR/run )

for RUN in $RUNS
do
  printf "%-10s " $RUN
  sed '/Current time/ {s/Current time ....\(.*\)/\1/ ; h}; $!d; x' \
      $DIR/run/$RUN/model.log
done > $TIMES

echo "extract-time.sh: wrote: $TIMES"
