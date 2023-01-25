# CFG PRM NIGHTLY

# mlrMBO settings

# Total iterations
PROPOSE_POINTS=${PROPOSE_POINTS:-5}
MAX_CONCURRENT_EVALUATIONS=${MAX_CONCURRET_EVALUATIONS:-1}
MAX_ITERATIONS=${MAX_ITERATIONS:-3}
MAX_BUDGET=${MAX_BUDGET:-180}
DESIGN_SIZE=${DESIGN_SIZE:-5}

# TODO: move the following code to a utility library-
#       this is a configuration file
# Set the R data file for running
if [ "$MODEL_NAME" = "combo" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/combo_nightly.R}
elif [ "$MODEL_NAME" = "attn" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/attn_nightly.R}
elif [ "$MODEL_NAME" = "adrp" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/adrp_nightly.R}
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
elif [ "$MODEL_NAME" = "graphdrp" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/graphdrp_small.R}
elif [ "$MODEL_NAME" = "dummy" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/dummy_nightly.R}
elif [ "$MODEL_NAME" = "oned" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/oned.R}
elif [[ "${PARAM_SET_FILE:-}" != "" ]]; then
    PARAM_SET_FILE=${EMEWS_PROJECT_ROOT}/data/${PARAM_SET_FILE}
else
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/graphdrp_small.R}
#    printf "Could not find PARAM_SET_FILE for model: '%s'\n" $MODEL_NAME
#    exit 1
fi
