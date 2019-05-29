#!/bin/bash

# Display timing/node/GPU information
echo "MODEL_WRAPPER.SH START TIME: $(date +%s)"
echo "HOST: $(hostname)"
echo "GPU: ${CUDA_VISIBLE_DEVICES:-NA}"

# Unload environment in which we built Swift/T
module unload $MODULES_FOR_BUILD

# Load a custom, SUPPlementary environment if it's set
if [ -n "$SUPP_MODULES" ]; then
    module load $SUPP_MODULES
fi

# Determine language to use to run the model
suffix=$(echo "$MODEL_SCRIPT" | rev | awk -v FS="." '{print tolower($1)}' | rev)

# Run a model written in Python
if [ "x$suffix" == "xpy" ]; then

    # Clear PYTHONHOME since historically that's caused us issues
    unset PYTHONHOME

    # If $PYTHON_BIN_PATH isn't null, prepend that to our $PATH
    if [ -n "$PYTHON_BIN_PATH" ]; then
        export PATH=$PYTHON_BIN_PATH:$PATH

    # Otherwise, load the $EXEC_PYTHON_MODULE if it's set, or $DEFAULT_PYTHON_MODULE if it's not
    else
        module load "${EXEC_PYTHON_MODULE:-$DEFAULT_PYTHON_MODULE}"
    fi

    echo "Using Python for execution: $(command -v python)"
    python "$MODEL_SCRIPT"

# Run a model written in R
elif [ "x$suffix" == "xr" ]; then
    module load "$DEFAULT_R_MODULE"
    echo "Using R for execution: $(command -v R)"
    R "$MODEL_SCRIPT"
fi

# Display timing information
echo "MODEL_WRAPPER.SH END TIME: $(date +%s)"