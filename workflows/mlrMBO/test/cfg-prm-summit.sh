# CFG PRM SUMMIT

# mlrMBO settings

# Total iterations
PROPOSE_POINTS=${PROPOSE_POINTS:-64}
MAX_CONCURRENT_EVALUATIONS=${MAX_CONCURRET_EVALUATIONS:-1}
MAX_ITERATIONS=${MAX_ITERATIONS:-3}
MAX_BUDGET=${MAX_BUDGET:-280}
DESIGN_SIZE=${DESIGN_SIZE:-64}

# TODO: move the following code to a utility library-
#       this is a configuration file
# Set the R data file for running
if [ "$MODEL_NAME" = "combo" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/combo_nightly.R}
elif [ "$MODEL_NAME" = "p1b1" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b1_nightly.R}
elif [ "$MODEL_NAME" = "nt3" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/nt3_nightly.R}
elif [ "$MODEL_NAME" = "p1b3" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b3_nightly.R}
elif [ "$MODEL_NAME" = "p1b2" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b2_nightly.R}
elif [ "$MODEL_NAME" = "p2b1" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p2b1_nightly.R}
elif [ "$MODEL_NAME" = "dummy" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/nt3_nightly.R}
elif [ "$PARAM_SET_FILE" != "" ]; then
    PARAM_SET_FILE=${EMEWS_PROJECT_ROOT}/data/${PARAM_SET_FILE}
else
    echo "Invalid model-" $MODEL_NAME
    exit 1
fi
