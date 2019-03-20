#!/bin/bash

# Site-specific settings
export CANDLE_DIR="/data/BIDS-HPC/public/candle"
export SITE="biowulf"


#### MODIFY ONLY BELOW ####################################################################
# Model specification
export MODEL_PYTHON_DIR="$CANDLE_DIR/Supervisor/templates/models/mnist"
export MODEL_PYTHON_SCRIPT="mnist_mlp"
export DEFAULT_PARAMS_FILE="$CANDLE_DIR/Supervisor/templates/model_params/mnist1.txt"

# Workflow specification
export WORKFLOW_TYPE="upf"
export WORKFLOW_SETTINGS_FILE="$CANDLE_DIR/Supervisor/templates/workflow_settings/upf3.txt"

# Job specification
export EXPERIMENTS="$(pwd)" # set this to, e.g., /home/weismanal/notebook/2019-03-18/test3 (this will contain the job output; ensure this directory exists)
export MODEL_NAME="mnist_upf_test"
export OBJ_RETURN="val_loss"

# Scheduler settings
export PROCS="4" # remember that PROCS-2 are actually used for computation
export PPN="1"
export WALLTIME="00:10:00"
export GPU_TYPE="k80" # the choices on Biowulf are p100, k80, v100, k20x
export MEM_PER_NODE="20G"
#### MODIFY ONLY ABOVE ####################################################################


# Call the workflow
$CANDLE_DIR/Supervisor/workflows/$WORKFLOW_TYPE/swift/workflow.sh $SITE -a $CANDLE_DIR/Supervisor/workflows/common/sh/cfg-sys-$SITE.sh $WORKFLOW_SETTINGS_FILE