# CFG PRM 1
# Configuration of parameters: 1

# mlrMBO settings
# How many to runs evaluate per iteration -> Adding the number of restart runs to the budget (101 - for the test case)
MAX_BUDGET=${MAX_BUDGET:-125}
# Total iterations
MAX_ITERATIONS=${MAX_ITERATIONS:-2}
DESIGN_SIZE=${DESIGN_SIZE:-8}
PROPOSE_POINTS=${PROPOSE_POINTS:-8}
PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/params_restart.R}
MODEL_NAME="p3b1"
