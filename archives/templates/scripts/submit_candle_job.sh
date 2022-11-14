#!/bin/bash

# Define the model and its default settings
export MODEL_SCRIPT="$CANDLE/Supervisor/templates/models/wrapper_compliant/mnist_mlp.py" # should be wrapper-compliant
export DEFAULT_PARAMS_FILE="$CANDLE/Supervisor/templates/model_params/mnist1.txt"

# Define the execution Python to use if you don't want to use the central Python environment on Biowulf (currently python/3.6) (if PYTHON_BIN_PATH is set, it takes precedence over EXEC_PYTHON_MODULE)
export PYTHON_BIN_PATH=                 # e.g., "$CONDA_PREFIX/envs/<YOUR_CONDA_ENVIRONMENT_NAME>/bin", "/data/BIDS-HPC/public/software/conda/envs/main3.6/bin"
export EXEC_PYTHON_MODULE=              # e.g., "python/2.7" (if unset [and PYTHON_BIN_PATH is unset], the Python used for model execution is $DEFAULT_PYTHON_MODULE, which is currently python/3.6)

# Define the execution environment
export SUPP_MODULES=                    # e.g., "CUDA/10.0 cuDNN/7.5/CUDA-10.0" (this is necessary for running tensorflow when using a local Conda Python)
export SUPP_PYTHONPATH=                 # e.g., "/home/weismanal/data/conda/envs/with_affine/lib/python3.6/site-packages", "/data/BIDS-HPC/public/software/conda/envs/main3.6/lib/python3.6/site-packages"

# Workflow settings
export WORKFLOW_TYPE="upf"
export WORKFLOW_SETTINGS_FILE="$CANDLE/Supervisor/templates/workflow_settings/upf3.txt"
export RESTART_FROM_EXP=

# Job specification
export EXPERIMENTS="$(pwd)/experiments" # this experiment will be created if it doesn't already exist; will contain the job output
export MODEL_NAME="sample_run_on_mnist_dataset"
export OBJ_RETURN="val_loss"

# Scheduler settings
export PROCS="3" # note that PROCS-1 and PROCS-2 are actually used for UPF and mlrMBO computations, respectively
export WALLTIME="00:20:00"
export GPU_TYPE="k80" # the choices on Biowulf are p100, k80, v100, k20x

# Determine whether to use CANDLE or to run a single job outside of CANDLE for testing purposes
export USE_CANDLE=1 # if not already set, as in e.g. by run_without_candle.sh, set to 1 to use CANDLE or 0 to run using the default parameters outside of CANDLE


################ MODIFY ONLY ABOVE; DO NOT MODIFY BELOW ####################################################################
$CANDLE/Supervisor/templates/scripts/run_workflows.sh
