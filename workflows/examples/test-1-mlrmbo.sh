#!/bin/bash

CANDLE=/data/BIDS-HPC/public/candle

export PROPOSE_POINTS=30
export DESIGN_SIZE=30
#export PROPOSE_POINTS=10
#export DESIGN_SIZE=10
export PROCS=6
export QUEUE=gpu
export WALLTIME=00:45:00
#export WALLTIME=00:20:00
GPU_TYPE=p100
export TURBINE_SBATCH_ARGS="--gres=gpu:${GPU_TYPE:-k20x}:1 --mem=${MEM_PER_NODE:-20G}"
export EXPERIMENTS=/home/weismanal/notebook/2019-02-04/testing_mlrmbo/experiments

#export MODEL_PYTHON_SCRIPT=cc_t29res
#export MODEL_PYTHON_DIR=/home/weismanal/checkouts/candle_tutorials/Topics/1_migrating_your_DNN_to_candle
#$CANDLE/Supervisor/workflows/mlrMBO/test/test-1.sh 010 biowulf -a

#export MODEL_PYTHON_SCRIPT=nt3_baseline_keras2
#export MODEL_PYTHON_DIR=$CANDLE/Benchmarks2/Pilot1/NT3
#$CANDLE/Supervisor/workflows/mlrMBO/test/test-1.sh nt3 biowulf -a

#export MODEL_PYTHON_SCRIPT=p1b1_baseline_keras2
#export MODEL_PYTHON_DIR=$CANDLE/Benchmarks2/Pilot1/P1B1
##$CANDLE/Supervisor/workflows/mlrMBO/test/test-1.sh blah biowulf -a
#$CANDLE/Supervisor/workflows/mlrMBO/test/test-1.sh p1b1 biowulf -a # timed out but a single interation was working

export MODEL_PYTHON_DIR=$CANDLE/Supervisor/workflows/examples
export MODEL_PYTHON_SCRIPT=unet
export DEFAULT_PARAMS_FILE=/home/weismanal/notebook/2019-02-04/testing_mlrmbo/kedar/default_params_kedar-small.txt
#export DEFAULT_PARAMS_FILE=/home/weismanal/notebook/2019-02-04/testing_mlrmbo/kedar/default_params_kedar-normal.txt
#export PARAM_SET_FILE=/home/weismanal/notebook/2019-02-04/testing_mlrmbo/kedar/kedar_params-simple.R # see Evernote note "mlrMBO parameters to try on Kedar's data" for more parameters to try
export PARAM_SET_FILE=/home/weismanal/notebook/2019-02-04/testing_mlrmbo/kedar/nt3_hps_exp_01.R
$CANDLE/Supervisor/workflows/mlrMBO/test/test-1.sh 0044 biowulf -a
