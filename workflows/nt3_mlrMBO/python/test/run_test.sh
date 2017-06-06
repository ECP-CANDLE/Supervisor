#! /usr/bin/env bash

NT3_DIR=../../../../../Benchmarks/Pilot1/NT3
export PYTHONPATH="$PWD/..:$NT3_DIR"

python test.py
