#!/bin/bash -l
set -eu

export PYTHONPATH=$PWD

python -u main.py

echo "main.sh: OK"
