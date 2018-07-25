#! /usr/bin/env bash

P1B1_DIR=../../../../../Benchmarks/Pilot1/P1B1
export PYTHONPATH="$PWD/..:$P1B1_DIR:../../../common/python"
echo $PYTHONPATH

python test_p1b1.py