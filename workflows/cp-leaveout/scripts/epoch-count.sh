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

LOGS=( $( find $DIR -name python.log  ) )
echo "epoch-count.sh: found ${#LOGS[@]} logs ..."
for LOG in ${LOGS[@]}
do
    echo -n "$LOG :: "
    # Pull out the last "Epoch:" line, print only the number:
    sed -n '/Epoch:/h;${g;s/.*Epoch: \([0-9]*\).*/\1/;p}' $LOG
done | nl # | sort -r -n -k 2 | column -t
