#!/bin/sh
set -eu

# PYTHONPATH
PP=
PP+=/soft/analytics/conda/env/Candle_ML/lib/python2.7/site-packages:
PP+=/soft/analytics/conda/env/Candle_ML/lib/python2.7:
PP+=$HOME/pb-data/auen-intel-tflow
# PYTHONHOME
PH=/soft/analytics/conda/env/Candle_ML

export MODE=cluster PROJECT=ExM QUEUE=default

THIS=$PWD

cd ~/pb-data
export TURBINE_OUTPUT_ROOT=$PWD
export TURBINE_OUTPUT_FORMAT=out-%Q
ENVS="-e PYTHONHOME=$PH -e PYTHONPATH=$PP"
swift-t -m cobalt $ENVS $THIS/py-keras.swift
