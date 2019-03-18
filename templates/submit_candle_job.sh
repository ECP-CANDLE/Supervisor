#!/bin/bash

# Directions:
#   (1) Copy this script to a working directory (doesn't have to be inside this directory tree)
#   (2) Modify the Bash variables in the indicated block below
#   (3) If necessary, create/modify the files pointed to by the $DEFAULT_PARAMS_FILE (default parameters for the MODEL) and $WORKFLOW_SETTINGS_FILE (default parameters for the WORKFLOW) variables
#   (4) Run "./submit_candle_jobs.sh"

# Notes:
#   * It's necessary to export the DEFAULT_PARAMS_FILE variable so that it can be picked up by the MODEL_PYTHON_SCRIPT by using the full pathname. E.g., if we just used the filename default_params.txt hardcoded into the MODEL_PYTHON_SCRIPT, the script would look for this global parameter file in the same directory that it's in (i.e., MODEL_PYTHON_DIR), but that would preclude using a MODEL_PYTHON_SCRIPT that's a symbolic link, i.e., we'd have to always copy the MODEL_PYTHON_SCRIPT to the current working directory, which is inefficient.
#   * Note that $obj_return is processed prior to MODEL_PYTHON_SCRIPT for some reason, but it should definitely be a parameter in the model

################ EDIT PARAMETERS BELOW ################
#### General settings
CANDLE=/data/BIDS-HPC/public/candle
TEMPLATES=$CANDLE/Supervisor/workflows/templates
EXPERIMENTS=/home/weismanal/notebook/2019-02-28/experiments
MODEL_NAME="testing_uno-mytest"
SITE=biowulf
OBJ_RETURN="val_dice_coef"
MAX_OR_MIN="max"

#### Scheduler settings
PROCS=2 # remember that PROCS-1 are actually used for UPF jobs (I think it's PROCS-2 for mlrMBO)
PPN=1
WALLTIME=12:00:00
GPU_TYPE=p100 # choices are p100, k80, v100, k20x
MEM_PER_NODE=20G # just moved down from 50G and may have to go back up if get memory issues!!!

#### Workflow settings
WORKFLOW_TYPE=upf
WORKFLOW_SETTINGS_FILE=$TEMPLATES/workflow_settings/upf2.txt
#WORKFLOW_TYPE=mlrMBO
#WORKFLOW_SETTINGS_FILE=$TEMPLATES/workflow_settings/mlrmbo2.R

#### Model settings
# UNO model:
#MODEL_PYTHON_DIR=$TEMPLATES/models/uno
#MODEL_PYTHON_SCRIPT=uno_baseline_keras2
#DEFAULT_PARAMS_FILE=$TEMPLATES/models/uno/default_params.txt

# Customizable U-Net model:
MODEL_PYTHON_DIR=$TEMPLATES/models/unet
MODEL_PYTHON_SCRIPT=model
DEFAULT_PARAMS_FILE=$TEMPLATES/models/unet/default_params.txt
# ResNet model:
#MODEL_PYTHON_DIR=$TEMPLATES/models/resnet
#MODEL_PYTHON_SCRIPT=model
#DEFAULT_PARAMS_FILE=$TEMPLATES/models/resnet/default_params.txt
################ EDIT PARAMETERS ABOVE ################

# Export variables needed later
export EMEWS_PROJECT_ROOT=$CANDLE/Supervisor/workflows/$WORKFLOW_TYPE MODEL_NAME OBJ_RETURN EXPERIMENTS PROCS PPN WALLTIME MODEL_PYTHON_DIR MODEL_PYTHON_SCRIPT GPU_TYPE MEM_PER_NODE DEFAULT_PARAMS_FILE

# Call the workflow
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a $CANDLE/Supervisor/workflows/common/sh/cfg-sys-${SITE}.sh $WORKFLOW_SETTINGS_FILE