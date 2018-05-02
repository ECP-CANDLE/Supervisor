#!/bin/bash -l
set -eu

export PYTHONPATH=$PWD

# Theta
PATH=/projects/Candle_ECP/swift/deps/Python-2.7.12/bin:$PATH
which python

nice python -u main.py $*

echo "main.sh: OK"
