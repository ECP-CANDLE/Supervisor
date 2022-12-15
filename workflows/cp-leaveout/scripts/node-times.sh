#!/bin/bash
set -eu

# NODE TIMES SH

THIS=$( readlink --canonicalize $( dirname $0 ) )
SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

set -x
python3 -u $THIS/node-times.py $*
