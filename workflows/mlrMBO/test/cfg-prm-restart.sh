# CFG PRM RESTART
# Configuration of parameters: 1

# mlrMBO settings
# How many to runs evaluate per iteration ->
	#Adding the number of restart runs to the budget (9 - for the test case)
	#This is the minimum number of runs required for restart 9 (greater than 8, which is the design size)
MAX_BUDGET=${MAX_BUDGET:-25}
# Total iterations
MAX_ITERATIONS=${MAX_ITERATIONS:-2}
DESIGN_SIZE=${DESIGN_SIZE:-6}
PROPOSE_POINTS=${PROPOSE_POINTS:-6}

# Set the default data file for running
if [ "$MODEL_NAME" = "combo" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b1_restart_params.R}
    RESTART_FILE=${RESTART_FILE=$EMEWS_PROJECT_ROOT/test/restart-combo.csv}
    RESTART_NUMBER=${RESTART_NUMBER=2}
elif [ "$MODEL_NAME" = "p1b1" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b1_restart_params.R}
elif [ "$MODEL_NAME" = "nt3" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/nt3_hps_exp_01.R}
elif [ "$MODEL_NAME" = "p1b3" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b3_hps_exp_01.R}
elif [ "$MODEL_NAME" = "p1b2" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b2_hps_exp_01.R}
else
    echo "Invalid model-" $MODEL_NAME
    exit
fi
