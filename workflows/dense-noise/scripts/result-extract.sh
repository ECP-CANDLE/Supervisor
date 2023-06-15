#!/bin/bash
set -eu

# PLOT EXTRACT SH

THIS=$( realpath $( dirname $0 ) )
D_N=$(  realpath $THIS/.. )
SUPERVISOR=$( realpath $D_N/../.. )

source $SUPERVISOR/workflows/common/sh/utils.sh

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

if ! [[ -d $DIR ]]
then
  echo "Does not exist: $DIR"
  exit 1
fi

EXPID=$( basename $DIR )
JOBID=""
if [[ -r $DIR/jobid.txt ]]
then
  # jobid.txt does not exist for non-scheduled workflows
  JOBID=$( cat $DIR/jobid.txt )
fi

echo "EXPID=$EXPID JOBID=${JOBID:-local}"

OUTS=( $DIR/out/out-*.txt )

echo "outputs: ${#OUTS[@]}"

grep --no-filename "result" ${OUTS[@]} > $DIR/out-all.txt

python $THIS/result-extract.py $DIR/out-all.txt $DIR/plot.h5
