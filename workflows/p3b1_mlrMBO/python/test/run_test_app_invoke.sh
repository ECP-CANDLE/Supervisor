#! /usr/bin/env bash


BENCHMARK_DIR=../../../../../Benchmarks/Pilot3/P3B1
COMMON_DIR=../../../common/python
export PYTHONPATH="$PWD/..:$BENCHMARK_DIR:$COMMON_DIR"

python ../p3b1_runner.py ./params.json ./ keras
