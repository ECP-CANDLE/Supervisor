#!/bin/sh
set -eu

# FIND LOSS INCREASES SH

# Checks that all nodes in the DB are in the PKL

# Input:  Provide an experiment directory
# Output: Information printed to screen (pipe this into less)

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

set -x
python3 -u $THIS/find-loss-increases.py $*
