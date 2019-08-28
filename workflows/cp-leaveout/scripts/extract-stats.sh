#!/bin/bash
set -eu

# EXTRACT R2 SH
# Extract R2s
# Provide a directory full of model.logs

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

# The output of this script, a plottable file
R2S=$DIR/r2s.txt

RUNS=$( ls $DIR/run )

for RUN in $RUNS
do
  printf "%-10s " $RUN
  sed '/r2:/ {s/.*]   r2: \(.*\)/\1/ ; h}; $!d; x' \
      $DIR/run/$RUN/model.log
done > $R2S

echo "extract-r2.sh: wrote: $R2S"
