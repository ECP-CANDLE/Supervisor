#!/bin/bash
set -eu

# EPOCH TIME SH
# Report average time per epoch by stage

THIS=$( readlink --canonicalize $( dirname $0 ) )
CPLO=$( readlink --canonicalize $THIS/.. )
SUPERVISOR=$( readlink --canonicalize $CPLO/../.. )

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

NODES=( $( ls $DIR/run | head -10000 ) ) #
echo "epoch-time.sh: found ${#NODES[@]} nodes ..."
{
  echo "epoch-time: total ${#NODES[@]}"
  for NODE in ${NODES[@]}
  do
    echo "epoch-time: node $NODE"
    PYTHON_LOG=$DIR/run/$NODE/save/python.log
    if [[ ! -e $PYTHON_LOG ]]
    then
      continue
    fi
    cat $PYTHON_LOG
  done
} | python $THIS/epoch-time.py
