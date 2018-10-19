# CFG PRM 1

# mlrMBO settings

# Total iterations
PROPOSE_POINTS=${PROPOSE_POINTS:-5}
MAX_CONCURRENT_EVALUATIONS=${MAX_CONCURRENT_EVALUATIONS:-1}
MAX_ITERATIONS=${MAX_ITERATIONS:-3}
MAX_BUDGET=${MAX_BUDGET:-180}
DESIGN_SIZE=${DESIGN_SIZE:-10}

# TODO: move the following code to a utility library-
#       this is a configuration file
# Set the R data file for running
if [ "$MODEL_NAME" = "combo" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/combo_hps_exp_01.R}
elif [ "$MODEL_NAME" = "p1b1" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b1_hps_exp_01.R}
elif [ "$MODEL_NAME" = "nt3" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/nt3_hps_exp_01.R}
elif [ "$MODEL_NAME" = "p1b3" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b3_hps_exp_01.R}
elif [ "$MODEL_NAME" = "p1b2" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b2_hps_exp_01.R}
elif [ "$MODEL_NAME" = "p2b1" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p2b1_param1.R}
fi

# For cc_t29res
# PARAM_SET_FILE=$EMEWS_PROJECT_ROOT/data/nt3_hps_exp_01.R

if [[ "${PARAM_SET_FILE:-}" == "" ]]; then
  # PARAM_SET_FILE must be set before this script returns!
  echo "Invalid model-" "'${MODEL_NAME:-}'"
  exit 1
fi
