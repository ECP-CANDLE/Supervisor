#! /usr/bin/env bash

NT3_DIR=../../../../../Benchmarks/Pilot1/NT3
TC1_DIR=../../../../../Benchmarks/Pilot1/TC1

export PYTHONPATH="$PWD/..:$NT3_DIR:$TC1_DIR"

python ../nt3_tc1_runner.py ./params.json ./ nt3
