#!/bin/bash

# Usage: ./submit_candle_job.sh
# Note: This script and the WORKFLOW_SETTINGS file should be the ONLY things to modify prior to running CANDLE jobs

# Constants
CANDLE=/data/BIDS-HPC/public/candle
SITE=biowulf
CFG_SYS=$CANDLE/Supervisor/workflows/common/sh/cfg-sys-${SITE}.sh
SCRIPTDIR=$(cd $(dirname $0); pwd) # obtain the directory in which this script (submit_candle_job.sh) lies in order to be optionally used in the settings below


################ EDIT PARAMETERS BELOW ################
# Scheduler settings
PROCS=9 # remember that PROCS-1 are actually used for DL jobs
PPN=1
WALLTIME=24:00:00
GPU_TYPE=p100 # choices are p100, k80, v100, k20x
MEM_PER_NODE=20G # just moved down from 50G and may have to go back up if get memory issues!!!

# Model settings that aren't gParameters (they're processed before the MODEL_PYTHON_SCRIPT)
# Note that $obj_return is also processed prior to MODEL_PYTHON_SCRIPT for some reason, but it should definitely be a parameter in the model
WORKFLOW_TYPE=upf # upf, mlrMBO, etc.
WORKFLOW_SETTINGS=$SCRIPTDIR/upf.txt # e.g., the unrolled parameter file
EXPERIMENTS=$SCRIPTDIR/experiments
MODEL_PYTHON_DIR=$CANDLE/Supervisor/workflows/examples
MODEL_PYTHON_SCRIPT=unet
MODEL_NAME="third_continuation_kedar_run"
DEFAULT_PARAMS_FILE=$SCRIPTDIR/default_params.txt # This file is written later by this script!  It's necessary to export this variable so that it can be picked up by the MODEL_PYTHON_SCRIPT by using the full pathname. E.g., if we just used the filename default_params.txt hardcoded into the MODEL_PYTHON_SCRIPT, the script would look this global parameter file in the same directory that it's in (i.e., MODEL_PYTHON_DIR), but that would preclude using a MODEL_PYTHON_SCRIPT that's a symbolic link, i.e., we'd have to always copy the MODEL_PYTHON_SCRIPT to the current working directory, which is inefficient

# [Global_Params]
images="/home/weismanal/links/1-pre-processing/roi1+roi2/both_rois_images_combined_5000-ready_for_unet.npy"
labels="/home/weismanal/links/1-pre-processing/roi1+roi2/both_rois_masks_combined_5000-ready_for_unet.npy"
initialize=None
predict=False
epochs=20
batch_size=2
activation="relu"
nlayers=5
conv_size=5
loss_func="dice"
num_filters=64
last_act="sigmoid"
dropout=None
batch_norm=False
lr="1e-5"
obj_return="val_loss"
################ EDIT PARAMETERS ABOVE ################


# Export variables needed later
export EMEWS_PROJECT_ROOT=$CANDLE/Supervisor/workflows/$WORKFLOW_TYPE MODEL_NAME OBJ_RETURN=$obj_return EXPERIMENTS PROCS PPN WALLTIME MODEL_PYTHON_DIR MODEL_PYTHON_SCRIPT GPU_TYPE MEM_PER_NODE DEFAULT_PARAMS_FILE

# Write the parameters file
global_params=(images labels initialize predict epochs batch_size activation nlayers conv_size loss_func num_filters last_act dropout batch_norm lr obj_return)
echo "[Global_Params]" > $DEFAULT_PARAMS_FILE
for i in ${global_params[@]}; do
    res=$(eval "echo \$$i")
    expr $res - 1 &> /dev/null
    if [ $? -eq 0 ]; then # it's a number
	quote=""
    else # it's a string
	if [ "a${res}" == "aFalse" -o "a${res}" == "aTrue" -o "a${res}" == "aNone" ]; then
	    quote=""
	else
	    quote="'"
	fi
    fi
    echo "${i}=${quote}${res}${quote}" >> $DEFAULT_PARAMS_FILE
done

# Call the workflow
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a $CFG_SYS $WORKFLOW_SETTINGS
