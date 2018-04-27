#!/bin/bash -l
set -x
set -eu

export PYTHONPATH=$PWD

python main.py
