#! /usr/bin/env bash

COMBO_DIR=../../../../../Benchmarks/Pilot1/Combo:../../../common/python
export PYTHONPATH="$PWD/..:$COMBO_DIR"

python test.py
