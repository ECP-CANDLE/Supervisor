#!/bin/sh
set -eu

# TEST PERMUTE

THIS=$( dirname $0 )
export PYTHONPATH=$THIS:${PYTHONPATH:-}

python $THIS/test-permute.py $*
