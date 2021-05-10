#!/bin/bash
set -eu

# EPOCH STATUS SH
# Report epoch progress status for all python.logs

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

LOGS=( $( find $DIR -name python.log  ) )
echo "epoch-count.sh: found ${#LOGS[@]} logs ..."

COMPLETED=0
for LOG in ${LOGS[@]}
do
  if grep -q "EPOCHS COMPLETED" $LOG
  then
    (( COMPLETED = COMPLETED+1 ))
  else
    echo
    echo $LOG
    tail $LOG
  fi
done
echo "COMPLETED: $COMPLETED"
