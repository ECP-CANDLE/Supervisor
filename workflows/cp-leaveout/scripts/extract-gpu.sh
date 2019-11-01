#!/bin/bash
set -eu

# EXTRACT GPU SH
# Extract GPU utilizations
# Provide a directory full of model.logs

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

# The stdout from the workflow (read by this script)
OUTPUT=$DIR/output.txt
# The output of this script
GPUS=$DIR/gpus.txt

RUNS=$( ls $DIR/run )

for RUN in $RUNS
do
  echo START
  # printf "%-10s " $RUN
  grep -A 1 "0  Tesla" $DIR/run/$RUN/perf-nvidia.log | \
    sed -n '/E\. Process/{s/.* \([0-9]*\)% .*/\1/ ; p}' \
        > $DIR/run/$RUN/util-gpu.log
done

echo "extract-gpu.sh: wrote: $GPUS"
