#!/bin/bash
set -eu

# REPORT LEAVES SH
# Report nodes with no children

THIS=$(       realpath $( dirname $0 ) )
CPLO=$(       realpath $THIS/.. )
SUPERVISOR=$( realpath $CPLO/../.. )

source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

if ! [[ -d $DIR ]]
then
  echo "Does not exist: $DIR"
  exit 1
fi

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

set -x
python3 -u $THIS/report_leaves.py $DIR
