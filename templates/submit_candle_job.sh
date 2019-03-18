#!/bin/bash

# Site-specific settings
export CANDLE_DIR="/data/BIDS-HPC/public/candle"
export SITE="biowulf"

# Job specification
export EXPERIMENTS="/home/weismanal/notebook/2019-02-28/experiments"
export MODEL_NAME="my_test_unet_using_upf"
export OBJ_RETURN="val_dice_coef"

# Scheduler settings
export PROCS="5" # remember that PROCS-1 are actually used for UPF jobs (it's PROCS-2 for mlrMBO)
export PPN="1"
export WALLTIME="04:00:00"
export GPU_TYPE="k80" # the choices on Biowulf are p100, k80, v100, k20x
export MEM_PER_NODE="20G"

# Model specification
export MODEL_PYTHON_DIR="$CANDLE_DIR/Supervisor/templates/models"
export MODEL_PYTHON_SCRIPT="unet"
export DEFAULT_PARAMS_FILE="$CANDLE_DIR/Supervisor/templates/model_params/unet1.txt"

# Workflow specification
export WORKFLOW_TYPE="upf"
export WORKFLOW_SETTINGS_FILE="$CANDLE_DIR/Supervisor/templates/workflow_settings/upf1.txt"

# Call the workflow
export EMEWS_PROJECT_ROOT="$CANDLE_DIR/Supervisor/workflows/$WORKFLOW_TYPE"
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a $CANDLE_DIR/Supervisor/workflows/common/sh/cfg-sys-$SITE.sh $WORKFLOW_SETTINGS_FILE