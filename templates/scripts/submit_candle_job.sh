#!/bin/bash

# Always load the candle module and the Python module in which we built Swift/T
module load candle python/3.6
export MODEL_PYTHON_DIR="$CANDLE/Supervisor/templates/scripts"
export MODEL_PYTHON_SCRIPT="candle_compliant_wrapper"


#### MODIFY ONLY BELOW ####################################################################
# Define the model and its environment
export MODEL_SCRIPT="/home/weismanal/notebook/2019-05-18/test_model.py"
#export DEFAULT_PARAMS_FILE="$CANDLE/Supervisor/templates/model_params/mnist1.txt"
export DEFAULT_PARAMS_FILE="/data/BIDS-HPC/private/projects/custom_model_sh/scpyParaTest1.txt"
export USE_R=0 # set to 0 to use Python (default) or to 1 to use R

# Define the model's execution environment
export MODULES_TO_LOAD="CUDA/10.0 cuDNN/7.5/CUDA-10.0"
export CONDA_ENV_NAME="kds_on_biowulf_clone_of_jurgen3.6"

# Workflow specification
export WORKFLOW_TYPE="upf"
#export WORKFLOW_SETTINGS_FILE="$CANDLE/Supervisor/templates/workflow_settings/upf3.txt"
export WORKFLOW_SETTINGS_FILE="/data/BIDS-HPC/private/projects/custom_model_sh/upf-shorter.txt"

# Job specification
export EXPERIMENTS="$(pwd)/experiments" # this will contain the job output; ensure this directory exists
export MODEL_NAME="mnist_upf_test"
export OBJ_RETURN="val_loss"

# Scheduler settings
export PROCS="4" # note that PROCS-1 and PROCS-2 are actually used for UPF and mlrMBO computations, respectively
export PPN="1"
export WALLTIME="00:10:00"
export GPU_TYPE="k80" # the choices on Biowulf are p100, k80, v100, k20x
export MEM_PER_NODE="20G"
#### MODIFY ONLY ABOVE ####################################################################


# Call the workflow; DO NOT MODIFY
#$CANDLE/Supervisor/workflows/$WORKFLOW_TYPE/swift/workflow.sh $SITE -a $CANDLE/Supervisor/workflows/common/sh/cfg-sys-$SITE.sh $WORKFLOW_SETTINGS_FILE
python $MODEL_PYTHON_DIR/$MODEL_PYTHON_SCRIPT.py