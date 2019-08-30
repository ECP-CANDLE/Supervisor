#!/bin/bash
set -eu

# EXTRACT STATS SH
# Extract stats: r2, mse, mae
# Provide a directory full of model.logs

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

# The output of this script, a plottable file
STATS_FILE=$DIR/stats.txt

RUNS=$( ls $DIR/run )

FORMAT="%-6s %-10s %-8s %-8s %-8s %-8s"

{
  printf "# $FORMAT\n" STAGE RUN R2 MSE MAE TIME
  for RUN in $RUNS
  do
    # echo $RUN >&2 # Uncomment for progress indication
    STAGE=$(( ${#RUN} / 2 )) # Length of run label, not counting dots
    STATS=()
    for TOKEN in r2 mae mse
    do
      STATS+=( $(
                 sed "/$TOKEN:/ {s/.*]   $TOKEN: \(.*\)/\1/ ; h}; \$!d; x" \
                     $DIR/run/$RUN/model.log
               ) )
    done
    STATS+=( $(
               sed "/Current time/ {s/Current time \.\.\.\.\(.*\)/\1/ ; h}; \$!d; x" \
                   $DIR/run/$RUN/model.log
             ) )
    printf "  $FORMAT\n" $STAGE $RUN ${STATS[@]}
  done
} > $STATS_FILE

echo "extract-stats.sh: wrote: $STATS_FILE"
