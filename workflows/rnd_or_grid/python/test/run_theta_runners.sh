#!/bin/bash

set -eu

# Theta / Tensorflow env vars
export KMP_BLOCKTIME=30
export KMP_SETTINGS=1
export KMP_AFFINITY=granularity=fine,verbose,compact,1,0
export OMP_NUM_THREADS=128

export PYTHONHOME="/lus/theta-fs0/projects/Candle_ECP/ncollier/py2_tf_gcc6.3_eigen3_native"
#export PYTHONHOME="/home/rjain/anaconda2"
PYTHON="$PYTHONHOME/bin/python"
export LD_LIBRARY_PATH="$PYTHONHOME/lib"
export PATH="$PYTHONHOME/bin:$PATH"

RUNNER_DIR=../../../../../Benchmarks/Pilot1/P1B1:../../../../../Benchmarks/Pilot2/P2B1:../../../../../Benchmarks/Pilot3/P3B1:../../../../../Benchmarks/Pilot1/NT3:../../../../../Benchmarks/Pilot1/P1B3
COMMON_DIR=../../../common/python
PYTHONPATH="$PYTHONHOME/lib/python2.7:"
PYTHONPATH+="../:$RUNNER_DIR:$COMMON_DIR:"
PYTHONPATH+="$PYTHONHOME/lib/python2.7/site-packages"
export PYTHONPATH
export PROJECT=Candle_ECP

echo $PYTHONPATH
$PYTHON test_runners.py
