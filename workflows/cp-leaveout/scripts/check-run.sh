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

if ! [[ -d $DIR ]]
then
  echo "Does not exist: $DIR"
  exit 1
fi

EXPID=$( basename $DIR )
JOBID=$( cat $DIR/jobid.txt )
show EXPID JOBID

# Assume failure:
SUCCESS=0

grep   "SUBMITTED:" $DIR/turbine.log
printf "STARTED:           "
date "+%Y-%m-%d %H:%M" -d "$( stat -c %y $DIR/turbine-env.txt | cut -b 1-19  )"

printf "STOPPED:           "
date "+%Y-%m-%d %H:%M" -d "$( stat -c %y $DIR/output.txt | cut -b 1-19  )"

if grep -q "User defined signal 2" $DIR/output.txt
then
  # Summit time out
  echo "Job timed out normally."
  SUCCESS=1

elif grep -q "DUE TO TIME LIMIT" $DIR/output.txt
then
  # Frontier time out
  echo "Job timed out normally."
  SUCCESS=1

elif grep -q "EXIT CODE: *0" $DIR/output.txt
then
  echo "Job completed normally."
  grep "MPIEXEC TIME: " $DIR/output.txt
  SUCCESS=1
fi

if (( ! SUCCESS ))
then
  grep "START:" $DIR/output.txt
  # Find task that failed, e.g.:
  grep "MPI_Abort" $DIR/output.txt || true
  # srun: error: frontier04081: task 1793: Exited with exit code 255
  grep "error: .* exit code" $DIR/output.txt || true
  # Find MPI Aborts on Frontier
  grep "srun: error: .* Aborted" $DIR/output.txt || true
  grep "slurmstepd: error:" $DIR/output.txt || true
  grep "MPICH .* Abort" $DIR/output.txt | \
    cut --delimiter ' ' --fields=1-12
fi

if (( ! SUCCESS ))
then
  echo "Job failed!"
  exit 1
fi

$CPLO/db/print-stats.sh $DIR/cplo.db
