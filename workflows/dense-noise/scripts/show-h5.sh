#!/bin/bash
set -eu

# SHOW H5 SH

THIS=$( realpath $( dirname $0 ) )
D_N=$(  realpath $THIS/.. )
SUPERVISOR=$( realpath $D_N/../.. )

source $SUPERVISOR/workflows/common/sh/utils.sh

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR KEY - ${*}

if ! [[ -d $DIR ]]
then
  echo "Directory does not exist: $DIR"
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

python $THIS/show-h5.py $DIR/plot.h5 $KEY
