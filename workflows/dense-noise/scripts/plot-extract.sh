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
JOBID=$( cat $DIR/jobid.txt )
show EXPID JOBID

OUTS=( $DIR/out/out-*.txt )

echo "outputs: ${#OUTS[@]}"

grep --no-filename "result" ${OUTS[@]} > $DIR/out-all.txt

python $THIS/plot-extract.py $DIR/out-all.txt $DIR/plot.h5