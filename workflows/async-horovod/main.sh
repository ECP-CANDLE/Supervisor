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

module load darshan
module load miniconda-3.6/conda-4.4.10

nice python -u main.py $*

STOP=$SECONDS

echo "main.sh: OK"
echo "TIME: $(( STOP - START ))"
