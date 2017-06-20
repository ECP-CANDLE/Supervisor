#! /usr/bin/env bash

NT3_DIR=../../../../../Benchmarks/Pilot1/NT3
TC1_DIR=../../../../../Benchmarks/Pilot1/TC1
COMMON_DIR="../../../common/python"

PARAM_STRING="$(<./params.json)"

export PYTHONPATH="$PWD/..:$NT3_DIR:$TC1_DIR:$COMMON_DIR"

python ../nt3_tc1_runner.py "$PARAM_STRING" ./ nt3 keras
