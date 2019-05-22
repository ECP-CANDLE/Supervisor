#!/bin/bash

# Display timing/node/GPU information
echo "MODEL_WRAPPER.SH START TIME: $(date +%s)"
echo "HOST: $(hostname)"
echo "GPU: ${CUDA_VISIBLE_DEVICES:-NA}"

# Unload environment in which we built Swift/T
module unload $MODULES_FOR_BUILD

# Load a custom environment if desired
if [ -n "$MODULES_TO_LOAD" ]; then
    module load $MODULES_TO_LOAD
fi
if [ -n "$CONDA_ENV_NAME" ]; then
    export PATH=$CONDA_PREFIX/envs/$CONDA_ENV_NAME/bin:$PATH
fi

# Determine language to use to run the model
suffix=$(echo $MODEL_SCRIPT | rev | awk -v FS="." '{print tolower($1)}' | rev)

# Run a model written in Python
if [ $suffix == "py" ]; then
    echo "Using Python..."
    unset PYTHONHOME
    python $MODEL_SCRIPT

# Run a model written in R
elif [ $suffix == "r" ]; then
    echo "Using R..."
fi

# Display timing information
echo "MODEL_WRAPPER.SH END TIME: $(date +%s)"