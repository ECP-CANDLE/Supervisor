
# CFG PRM 1
# Configuration of parameters: 1
# Original settings from monolithic workflow shell script

# mlrMBO settings
# How many to runs evaluate per iteration
MAX_BUDGET=${MAX_BUDGET:-1200}
# Total iterations
MAX_ITERATIONS=${MAX_ITERATIONS:-4}
DESIGN_SIZE=${DESIGN_SIZE:-30}
PROPOSE_POINTS=${PROPOSE_POINTS:-30}
PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/parameter_set3.R}
MODEL_NAME="p3b1"
# pbalabra:
# PARAM_SET_FILE="$EMEWS_PROJECT_ROOT/data/parameter_set1.R"
