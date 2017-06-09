#! /usr/bin/env bash


BENCHMARK_DIR=../../../../../Benchmarks/Pilot2/P2B1
COMMON_DIR=../../../common/python
export PYTHONPATH="$PWD/..:$BENCHMARK_DIR:$COMMON_DIR"

KERAS_BACKEND="theano" python ../p2b1_runner.py ./params.json ./ keras
