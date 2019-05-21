#!/bin/bash

# Display timing/node/GPU information
echo "MODEL_WRAPPER.SH START TIME: $(date +%s)"
echo "HOST: $(hostname)"
echo "GPU: ${CUDA_VISIBLE_DEVICES:-NA}"

# Unload environment in which we built Swift/T
module unload python/3.6

# Load a custom environment if desired
if [ -n "$MODULES_TO_LOAD" ]; then
    module load $MODULES_TO_LOAD
fi
if [ -n "$CONDA_ENV_NAME" ]; then
    source $(conda info --base)/etc/profile.d/conda.sh
    conda activate "$CONDA_ENV_NAME"
fi

# Run a model written in R
if [ "x$USE_R" == "x1" ]; then
    echo "Using R..."

# Run a model written in Python
else
    echo "Using Python..."
    unset PYTHONHOME
    python $MODEL_SCRIPT
fi

# Display timing information
echo "MODEL_WRAPPER.SH END TIME: $(date +%s)"