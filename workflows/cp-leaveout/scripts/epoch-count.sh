#!/bin/bash
set -eu

# EPOCH COUNT SH
# Report run progress in number of completed epochs

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

# Must use TMPFILE to avoid subshell for shell variables
mkdir -pv /tmp/$USER
TMPFILE=/tmp/$USER/epoch-count-XXX.tmp

EARLIES=0
LOGS=( $( find $DIR -name python.log ) )
TOTAL=${#LOGS[@]}
echo "epoch-count.sh: found $TOTAL logs ..."
for LOG in ${LOGS[@]}
do
    echo -n "$LOG :: "
    # Pull out the last "Epoch:" line, print only the number:
    EPOCH=$( sed -n '/Epoch:/h;${g;s/.*Epoch: \([0-9]*\).*/\1/;p}' $LOG )
    if grep -q "stopping: early" $LOG
    then
      EARLY="EARLY"
      (( EARLIES += 1 ))
    else
      EARLY=""
    fi
    echo $EPOCH $EARLY
done > $TMPFILE
cat $TMPFILE | nl | sort -r -n -k 4 | column -t
echo "earlies: $EARLIES / $TOTAL"
