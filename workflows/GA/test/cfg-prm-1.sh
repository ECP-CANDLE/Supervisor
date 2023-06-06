# CFG PRM 1

# GA settings

SEED=${SEED:-1}
# Total iterations
NUM_ITERATIONS=${NUM_ITERATIONS:-5}
# Size of GA population
# (i.e. the number of parameter sets to evaluate per iteration)
POPULATION_SIZE=${POPULATION_SIZE:-8}
# the GA strategy: one of 'simple' or 'mu_plus_lambda'. See
# https://deap.readthedocs.io/en/master/api/algo.html?highlight=eaSimple#module-deap.algorithms
# for more info.
GA_STRATEGY=${STRATEGY:-simple}

# Set IGNORE_ERRORS=1 to ignore model errors and
#     allow NaNs in model results:
# export IGNORE_ERRORS=1

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
elif [ "$MODEL_NAME" = "graphdrp" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/graphdrp_param_space_ga.json}
elif [ "$MODEL_NAME" = "tc1" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/tc1_param_space_ga.json}
elif [ "$MODEL_NAME" = "oned" ]; then
    PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/oned_param_space_ga.json}
# TODO: Uncomment when parameter files are available
# elif [ "$MODEL_NAME" = "p1b3" ]; then
#     PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b3_param_space_ga.json}
# elif [ "$MODEL_NAME" = "p1b2" ]; then
#     PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b2_param_space_ga.json}
# elif [ "$MODEL_NAME" = "p2b1" ]; then
#     PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p2b1_param_space_ga.json}
elif [ "${PARAM_SET_FILE:-}" != "" ]; then
    PARAM_SET_FILE=${EMEWS_PROJECT_ROOT}/data/${PARAM_SET_FILE}
else
    echo "Invalid model-" $MODEL_NAME
    exit 1
fi
