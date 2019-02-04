#!/bin/bash

CANDLE=/data/BIDS-HPC/public/candle

export MODEL_PYTHON_SCRIPT=cc_t29res
export MODEL_PYTHON_DIR=/home/weismanal/checkouts/candle_tutorials/Topics/1_migrating_your_DNN_to_candle
export PROPOSE_POINTS=30
export DESIGN_SIZE=30
export PROCS=6
export QUEUE=gpu
export WALLTIME=00:60:00
export TURBINE_SBATCH_ARGS="--gres=gpu:${GPU_TYPE:-k20x}:1 --mem=${MEM_PER_NODE:-20G}"

$CANDLE/Supervisor/workflows/mlrMBO/test/test-1.sh 000 biowulf -a
