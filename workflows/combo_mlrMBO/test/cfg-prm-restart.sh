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
MAX_CONCURRENT_EVALUATIONS=${MAX_CONCURRENT_EVALUATIONS:-6}
PROPOSE_POINTS=${PROPOSE_POINTS:-6}
PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/parameter_set.R}
MODEL_NAME="combo"

