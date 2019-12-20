#!/bin/sh
set -eu

# FIND LOSS INCREASES SH

# Does val_loss and val_loss delta analysis across the run

# Input:  Provide an experiment directory
# Output: Information printed to screen (pipe this into less)

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

set -x
python3 -u $THIS/find-loss-increases.py $*
