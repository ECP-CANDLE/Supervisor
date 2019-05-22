#!/bin/bash

# Always load the candle module
module load candle/2019-04-04
################ MODIFY ONLY BELOW; DO NOT MODIFY ABOVE ####################################################################


# Determine whether to use CANDLE or to run a single job outside of CANDLE for testing purposes
USE_CANDLE=${USE_CANDLE:-1} # if not already set, as in e.g. by run_without_candle.sh, set to 1 to use CANDLE or 0 to run outside of CANDLE

# Define the model and its environment
export MODEL_SCRIPT="$CANDLE/Supervisor/templates/models/wrapper_compliant/mnist_mlp.py" # should be wrapper-compliant
export DEFAULT_PARAMS_FILE="$CANDLE/Supervisor/templates/model_params/mnist1.txt"

# Define the model's execution environment
export MODULES_TO_LOAD="python/3.6"
export CONDA_ENV_NAME=

# Workflow specification
export WORKFLOW_TYPE="upf"
export WORKFLOW_SETTINGS_FILE="$CANDLE/Supervisor/templates/workflow_settings/upf3.txt"

# Job specification
export EXPERIMENTS="$(pwd)/experiments" # this will contain the job output; ensure this directory exists, as it will if copy_candle_template was run
export MODEL_NAME="sample_run_on_mnist_dataset"
export OBJ_RETURN="val_loss"

# Scheduler settings
export PROCS="3" # note that PROCS-1 and PROCS-2 are actually used for UPF and mlrMBO computations, respectively
export PPN="1"
export WALLTIME="00:20:00"
export GPU_TYPE="k80" # the choices on Biowulf are p100, k80, v100, k20x
export MEM_PER_NODE="20G"


################ MODIFY ONLY ABOVE; DO NOT MODIFY BELOW ####################################################################

export MODULES_FOR_BUILD="python/3.6"
export MODEL_PYTHON_DIR="$CANDLE/Supervisor/templates/scripts"
export MODEL_PYTHON_SCRIPT="candle_compliant_wrapper"
module load $MODULES_FOR_BUILD # load the module with which Swift/T was built

if [ $USE_CANDLE -eq 1 ]; then
    $CANDLE/Supervisor/workflows/$WORKFLOW_TYPE/swift/workflow.sh $SITE -a $CANDLE/Supervisor/workflows/common/sh/cfg-sys-$SITE.sh $WORKFLOW_SETTINGS_FILE
else
    python $MODEL_PYTHON_DIR/$MODEL_PYTHON_SCRIPT.py
fi