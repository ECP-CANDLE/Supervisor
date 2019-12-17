#!/bin/bash
set -eu

# CHECK RUN SH
# Report the status of a run: checks for normal exit and common errors

THIS=$( readlink --canonicalize $( dirname $0 ) )
CPLO=$( readlink --canonicalize $THIS/.. )
SUPERVISOR=$( readlink --canonicalize $CPLO/../.. )

source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

if ! [ -d $DIR ]
then
  echo "Does not exist: $DIR"
  exit 1
fi

EXPID=$( basename $DIR )
JOBID=$( cat $DIR/jobid.txt )
show EXPID JOBID

SUCCESS=0

if grep -q "User defined signal 2" $DIR/output.txt
then
  echo "Job timed out normally."
  SUCCESS=1
fi

if grep -q "TURBINE: EXIT CODE: 0" $DIR/output.txt
then
  echo "Job completed normally."
  grep "TURBINE: MPIEXEC TIME: " $DIR/output.txt
  SUCCESS=1
fi

if (( ! SUCCESS ))
then
  echo "Job failed!"
  exit 1
fi

$CPLO/db/print-stats.sh $DIR/cplo.db
