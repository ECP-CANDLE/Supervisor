#!/bin/bash

# For now set the default Python module for execution to be the same as that used for the CANDLE/Swift/T build
# We assume that the modules for the build are a single Python module
export DEFAULT_PYTHON_MODULE="$MODULES_FOR_BUILD"

# These are constants referring to the CANDLE-compliant wrapper Python script
export MODEL_PYTHON_DIR="$CANDLE/Supervisor/templates/scripts"
export MODEL_PYTHON_SCRIPT="candle_compliant_wrapper"

# Set a proportional number of processors to use on the node
export CPUS_PER_TASK=14
if [ "x$(echo $GPU_TYPE | awk '{print tolower($1)}')" == "xk20x" ]; then
    export CPUS_PER_TASK=16
fi

# Set a proportional amount of memory to use on the node
export MEM_PER_NODE="30G"
if [ "x$(echo $GPU_TYPE | awk '{print tolower($1)}')" == "xk20x" ] || [ "x$(echo $GPU_TYPE | awk '{print tolower($1)}')" == "xk80" ]; then
    export MEM_PER_NODE="60G"
fi

# For running the workflows themselves, load the module with which Swift/T was built
module load $MODULES_FOR_BUILD

# If we want to run the wrapper using CANDLE... 
if [ "${USE_CANDLE:-1}" -eq 1 ]; then
    "$CANDLE/Supervisor/workflows/$WORKFLOW_TYPE/swift/workflow.sh" "$SITE" -a "$CANDLE/Supervisor/workflows/common/sh/cfg-sys-$SITE.sh" "$WORKFLOW_SETTINGS_FILE"

# ...otherwise, run the wrapper alone, outside of CANDLE
else
    python "$MODEL_PYTHON_DIR/$MODEL_PYTHON_SCRIPT.py"
fi