#!/bin/bash
set -eu

# PRINT NODE INFO SH

# Input:  Provide an experiment directory
# Output: Node information printed to screen (pipe this into less)
# See Node.str_table() for the output format

THIS=$( readlink --canonicalize $( dirname $0 ) )
SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

set -x
python3 -u $THIS/print-node-info.py ${*}
