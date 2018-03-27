#! /usr/bin/env bash
set -eu

THIS=$( cd $( dirname $0 ) ; /bin/pwd )

BENCHMARKS=$HOME/Documents/repos/Benchmarks
SUPERVISOR=$PWD/../../../..

PYTHONPATH=$BENCHMARKS/Pilot1/common
PYTHONPATH+=":$BENCHMARKS/common"
PYTHONPATH+=":$SUPERVISOR/workflows/common/python"

export PYTHONPATH=$PYTHONPATH

python $THIS/../TC1/tc1_baseline_keras2.py --conv 0 0 0 --feature_subsample 1000
