#!/bin/bash
set -eu

# EXTRACT SH
# Extract load levels for the load/time plotter (load.py)
# Provide a directory full of model.logs

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

# The stdout from the workflow (read by this script)
OUTPUT=$DIR/output.txt
# The output of this script, a plottable file
SUMMARY=$DIR/summary.txt

# Get the overall start/stop times from the Turbine stdout
check "test -f $OUTPUT" "Could not find: $OUTPUT"
DATE_START=$( sed -n 's/.*DATE START: \(.*\)/\1/p' $DIR/output.txt )
DATE_STOP=$(  sed -n 's/.*DATE STOP:  \(.*\)/\1/p' $DIR/output.txt )
assert $(( ${#DATE_START} > 0 )) "DATE START not found!"
assert $(( ${#DATE_START} > 0 )) "DATE STOP  not found!"

# Get the model start/stop times from the model.logs
T=$( mktemp extract-XXX --suffix .txt )
MODEL_LOGS=$( find $DIR -name model.log )
for LOG in $MODEL_LOGS
do
  grep "model_runner: RUN" $LOG
done | sort -k 2 > $T

# Make the summary
python3 $SUPERVISOR/scratch/load/load.py \
 "$DATE_START" "$DATE_STOP" < $T > $SUMMARY
set -x
# python3 $SUPERVISOR/scratch/load/load.py \
#        "$DATE_START":00 "$DATE_STOP":00 < $T > $SUMMARY
rm $T

echo "extract.sh: wrote: $SUMMARY"
