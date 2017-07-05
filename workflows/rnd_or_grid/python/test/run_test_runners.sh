#! /usr/bin/env bash

RUNNER_DIR=../../../../../Benchmarks/Pilot1/P1B1:../../../../../Benchmarks/Pilot2/P2B1:../../../../../Benchmarks/Pilot3/P3B1:../../../../../Benchmarks/Pilot1/NT3:../../../../../Benchmarks/Pilot1/P1B3
export PYTHONPATH="$PWD/..:$RUNNER_DIR:../../../common/python"
echo $PYTHONPATH

python test_runners.py