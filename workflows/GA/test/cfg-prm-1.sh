# CFG PRM 1

# GA settings

# Total iterations
SEED=${SEED:-1}
NUM_ITERATIONS=${NUM_ITERATIONS:-2}
POPULATION_SIZE=${POPULATION_SIZE:-4}
GA_STRATEGY=${STRATEGY:-simple}

INIT_PARAMS_FILE=${INIT_PARAMS_FILE:-}

# TODO: move the following code to a utility library-
#       this is a configuration file
# Set the ga parameter space definition file for running
if [ "$MODEL_NAME" = "combo" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/combo_param_space_ga.json}
elif [ "$MODEL_NAME" = "p1b1" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b1_param_space_ga.json}
elif [ "$MODEL_NAME" = "nt3" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/nt3_param_space_ga.json}
elif [ "$MODEL_NAME" = "tc1" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/tc1_param_space_ga.json}
elif [ "$MODEL_NAME" = "p1b3" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b3_param_space_ga.json}
elif [ "$MODEL_NAME" = "p1b2" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b2_param_space_ga.json}
elif [ "$MODEL_NAME" = "p2b1" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p2b1_param_space_ga.json}
elif [ "$PARAM_SET_FILE" != "" ]; then
    PARAM_SET_FILE=${EMEWS_PROJECT_ROOT}/data/${PARAM_SET_FILE}
else
    echo "Invalid model-" $MODEL_NAME
    exit 1
fi
