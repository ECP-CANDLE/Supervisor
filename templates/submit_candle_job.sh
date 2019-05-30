#!/bin/bash

# Always load the candle module
#module load candle # removing this because we should do this on the command line


#### MODIFY ONLY BELOW ####################################################################
# Load desired Python version or Conda environment
# Load other custom environment settings here
module load $MODULES_FOR_BUILD

# Model specification
export MODEL_PYTHON_DIR="$CANDLE/Supervisor/templates/models/mnist"
export MODEL_PYTHON_SCRIPT="mnist_mlp"
export DEFAULT_PARAMS_FILE="$CANDLE/Supervisor/templates/model_params/mnist1.txt"

# Workflow specification
export WORKFLOW_TYPE="upf"
export WORKFLOW_SETTINGS_FILE="$CANDLE/Supervisor/templates/workflow_settings/upf3.txt"

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
$CANDLE/Supervisor/workflows/$WORKFLOW_TYPE/swift/workflow.sh $SITE -a $CANDLE/Supervisor/workflows/common/sh/cfg-sys-$SITE.sh $WORKFLOW_SETTINGS_FILE
