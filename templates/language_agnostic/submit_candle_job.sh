#!/bin/bash

# Site-specific settings
MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export CANDLE_DIR="/data/BIDS-HPC/public/candle"
export SITE="biowulf"

# Job specification
export EXPERIMENTS="$MY_DIR"
#TODO GZ: These 2 variables are not needed
export MODEL_NAME="mnist_upf_test" 
export OBJ_RETURN="val_loss"

# Scheduler settings
export PROCS="5" # remember that PROCS-2 are actually used for computation
export PPN="1"
export WALLTIME="00:30:00"
export GPU_TYPE="k80" # the choices on Biowulf are p100, k80, v100, k20x
export MEM_PER_NODE="20G"

# Model specification
export MODEL_SH=$MY_DIR/model.sh
#TODO: GZ: These are not needed
export MODEL_PYTHON_DIR="$CANDLE_DIR/Supervisor/templates/models/mnist"
export MODEL_PYTHON_SCRIPT="mnist_mlp"
export DEFAULT_PARAMS_FILE="$CANDLE_DIR/Supervisor/templates/model_params/mnist1.txt"


# Workflow specification
export WORKFLOW_TYPE="upf"
export WORKFLOW_SETTINGS_FILE="$CANDLE_DIR/Supervisor/templates/workflow_settings/upf3.txt"

# Call the workflow
export EMEWS_PROJECT_ROOT="$CANDLE_DIR/Supervisor/workflows/$WORKFLOW_TYPE"
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a $CANDLE_DIR/Supervisor/workflows/common/sh/cfg-sys-$SITE.sh $WORKFLOW_SETTINGS_FILE
