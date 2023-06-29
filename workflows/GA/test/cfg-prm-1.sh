# CFG PRM 1

# GA settings

SEED=${SEED:-1}
# Total iterations
NUM_ITERATIONS=${NUM_ITERATIONS:-5}
# Size of GA population
# (i.e. the number of parameter sets to evaluate per iteration)
POPULATION_SIZE=${POPULATION_SIZE:-16}
# the GA strategy: one of 'simple' or 'mu_plus_lambda'. See
# https://deap.readthedocs.io/en/master/api/algo.html?highlight=eaSimple#module-deap.algorithms
# for more info.
GA_STRATEGY=${STRATEGY:-mu_plus_lambda}
# RW: Probability that an individual is selected to mutate. Set to 1 to ensure consistent number
#     of evals (make use of all waiting GPUs)
MUT_PROB=${MUTATION_PROBABILITY:-1}
# RW: Probability that a pair of individuals are selected to cross (mate)
# RW: set to 0 for 1D because crossover doesn't do anything (Uniform crossover switches genes,
#     not average. In 1D, switching values just swaps individuals)
CX_PROB=${CROSSOVER_PROBABILITY:-0}
# RW: Probability for each gene to be mutated in a mutated individual
# RW: Set to 1 so that every time an individual is selected as a potential mutant and re-evaluated,
#     their genes actually change. Could set to lower probability for higher-dimensional spaces
MUT_INDPB=${GENE_MUTATION_PROBABILITY:-1}
# RW: Probability for each gene to be crossed in a mated pair
CX_INDPB=${GENE_CROSSOVER_PROBABILITY:-0.5}
# Size of tournaments
TOURNSIZE=${TOURNAMENT_SIZE:-4}

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
