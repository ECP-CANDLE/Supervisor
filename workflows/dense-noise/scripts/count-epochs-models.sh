#!/bin/bash
set -eu

# COUNT EPOCHS MODELS SH
# Count epochs completed in model.logs

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

LOGS=( $( find $DIR -name model.log ) )
TOTAL=${#LOGS[@]}
echo "count-epochs-models.sh: found $TOTAL logs ..."

grep -c "Epoch " ${LOGS[@]} > $DIR/epochs.txt

printf "Epochs: "
cut -d : -f 2 $DIR/epochs.txt | awk -f $THIS/sum.awk
