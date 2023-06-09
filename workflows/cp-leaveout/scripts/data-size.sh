#!/bin/bash
set -eu

# DATA SIZE SH
# See data-size.py

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

set -x
python3 $THIS/data-size.py $*
