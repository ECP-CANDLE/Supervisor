#! /usr/bin/env bash

BENCHMARK_DIR=../../../../../Benchmarks/Pilot1/P1B3
COMMON_DIR=../../../common/python
export PYTHONPATH="$PWD/..:$BENCHMARK_DIR:$COMMON_DIR"

python test.py
