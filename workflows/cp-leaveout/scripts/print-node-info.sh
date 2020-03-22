#!/bin/bash
set -eu

# PRINT NODE INFO SH

# Input:  Provide an experiment directory
# Output: Node information printed to screen (pipe this into less)

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

set -x
python3 -u $THIS/print-node-info.py $DIR
