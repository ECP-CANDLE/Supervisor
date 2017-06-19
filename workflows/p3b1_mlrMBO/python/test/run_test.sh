#! /usr/bin/env bash

THIS=$( cd $( dirname $0 ) ; /bin/pwd )

BENCHMARK_DIR=$( cd $THIS/../../../../../Benchmarks/Pilot3/P3B1 ; /bin/pwd )
COMMON_DIR=$( cd $THIS/../../../common/python ; /bin/pwd )
export PYTHONPATH="$THIS/..:$BENCHMARK_DIR:$COMMON_DIR"

echo $PYTHONPATH | tr : '\n' | nl

python $THIS/test.py
