#!/bin/bash -l

module load gcc/6.4.0
module load spectrum-mpi
module load cuda/9.2.148

export PATH=/gpfs/alpine/world-shared/med106/miniconda3/bin:$PATH
export LD_LIBRARY_PATH=/gpfs/alpine/world-shared/med106/miniconda3/lib:$LD_LIBRARY_PATH

echo MODEL.SH

echo BENCHMARKS_ROOT=$BENCHMARKS_ROOT

export OBJ_RETURN="val_loss"
export MODEL_NAME="nt3"
export EXPID="00"
export PYTHONPATH=$BENCHMARKS_ROOT/Pilot1/NT3

MODEL_RUNNER=$SUPERVISOR_ROOT/workflows/common/python/model_runner.py

set -x
which python3
# python3 model.py
python3 $MODEL_RUNNER "{}" $PWD/X "keras" "00" "60"
