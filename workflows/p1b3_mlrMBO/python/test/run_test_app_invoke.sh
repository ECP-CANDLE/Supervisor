#! /usr/bin/env bash

P1B3_DIR=../../../../../Benchmarks/Pilot1/P1B3
export PYTHONPATH="$PWD/..:$P1B3_DIR"

python ../p1b3_runner.py ./params.json ./
