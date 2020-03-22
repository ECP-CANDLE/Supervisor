#!/bin/bash
set -eu

# WORKFLOW STATS ALL SH

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

DIRS=(   X157 X153 X154 X158 X159 )
TOKENS=( F-20 F-10 LINE SQRT LOG2 )

set -x
for i in {0..4}
do
  $THIS/workflow-stats.sh --percentile --token ${TOKENS[$i]} \
                          experiments/RSIF/${DIRS[$i]}
done
