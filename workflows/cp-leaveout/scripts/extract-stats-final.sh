#!/bin/bash
set -eu

# EXTRACT STATS FINAL SH
# Extract stats: r2, mse, mae
# Provide a directory full of model.logs

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

# The output of this script, a plottable file
STATS_FILE=$DIR/stats_final.txt

RUNS=$( ls $DIR/run )

FORMAT="%-6s %-10s %-8s %-8s %-8s %-8s"

{
  printf "# $FORMAT\n" STAGE RUN VAL_LOSS VAL_R2 VAL_MAE
  for RUN in $RUNS
  do
    # echo $RUN >&2 # Uncomment for progress indication
    STAGE=$(( ${#RUN} / 2 )) # Length of run label, not counting dots
    STATS=()
    for TOKEN in val_loss val_r2 val_mae
    do
      STATS+=( $(
                 sed "/Epoch:/ {s/\(.*\), $TOKEN: \([0-9\.\-]*\)\(.*\)/\2/ ; h}; \$!d; x" \
                     $DIR/run/$RUN/model.log
               ) )
    done
    if [ ${#STATS[@]} -gt 0 ]
    then
        printf "  $FORMAT\n" $STAGE $RUN ${STATS[@]}
    fi
  done
} > $STATS_FILE

echo "extract-stats.sh: wrote: $STATS_FILE"
