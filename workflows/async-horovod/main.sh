#!/bin/bash
set -eu

# MAIN SH
# Shell wrapper for search code
# Use 'main.sh -h' for help

START=$SECONDS

export PYTHONPATH=$PWD

# Theta
PATH=/projects/Candle_ECP/swift/deps/Python-2.7.12/bin:$PATH
which python

# module load darshan
# module load miniconda-3.6/conda-4.4.10

echo MAIN.SH

THIS=$( readlink --canonicalize-existing $( dirname $0 ) )


if nice python -u $THIS/main.py $*
then
  CODE=$?
  echo "main.sh: OK"
else
  CODE=$?
  echo "main.sh: FAIL: python exited with code: $CODE"
fi

STOP=$SECONDS
echo "TIME: $(( STOP - START ))"

exit $CODE
