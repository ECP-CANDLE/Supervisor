#!/bin/bash
set -eu

# CHECK DB PKL SH

# Checks that all nodes in the DB are in the PKL

# Input:  Provide an experiment directory
# Output: Information printed to screen (pipe this into less)

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

set -x
python3 -u $THIS/check-db-pkl.py $DIR
