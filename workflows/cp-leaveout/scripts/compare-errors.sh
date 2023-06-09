#!/bin/bash
set -eu

# COMPARE ERRORS SH
# Compare errors from $DIR1/node-info.pkl and $DIR2/node-info.pkl
# See compare-errors.py

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

set -x
python3 -u $THIS/compare-errors.py $*
