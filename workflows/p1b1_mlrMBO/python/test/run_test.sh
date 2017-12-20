#! /usr/bin/env bash

P1B1_DIR=../../../../../Benchmarks/Pilot1/P1B1:../../../common/python

export PYTHONPATH="$PWD/..:$P1B1_DIR"

python test.py
