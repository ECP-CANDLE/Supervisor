#!/bin/bash
set -eu

# WORKFLOW STATS SH

# Input:  Provide an experiment directory
# Output: Node information printed to screen

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

set -x
python3 -u $THIS/workflow-stats.py ${*}
