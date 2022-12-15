#!/bin/bash
set -eu

# COMPARE LOSSES SH
# Compare losses from $DIR1/node-info.pkl and $DIR2/node-info.pkl

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide 2 experiment DIRs (e.g., .../experiments/X042)!" \
          DIR1 DIR2 - ${*}

for DIR in $DIR1 $DIR2
do
  if [[ ! -d $DIR ]]
  then
    echo "$0: Given experiment directory does not exist: $DIR"
    exit 1
  fi
done

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

set -x
python3 -u $THIS/compare-losses.py $DIR1 $DIR2 > compared-losses.txt
awk '{print $3, $4}' < compared-losses.txt > compared-losses.data
sort -n compared-losses.data | nl --number-width=2 \
                                  > compared-losses-sorted.data
