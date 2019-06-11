# CFG PRM 1

# mlrMBO settings

# Total runs/points/models per iteration
PROPOSE_POINTS=${PROPOSE_POINTS:-3}
# Total runs/points/models in first round
DESIGN_SIZE=${DESIGN_SIZE:-3}

# MAX_CONCURRENT_EVALUATIONS=${MAX_CONCURRENT_EVALUATIONS:-1}
MAX_ITERATIONS=${MAX_ITERATIONS:-3}
MAX_BUDGET=${MAX_BUDGET:-180}

# Directory ocation of the pregenerated train and test data frames (e.g CTRP_CCLE_2000_1000_train.h5)
CACHE_DIR=$EMEWS_PROJECT_ROOT/cache
# Directory location of cross correlation feature files (e.g. CCLE_GDSC_2000_1000_features.txt)
XCORR_DATA_DIR=$EMEWS_PROJECT_ROOT/xcorr_data

export PREPROP_RNASEQ="combat"

export RNA_SEQ_DATA=$BENCHMARKS_ROOT/Data/Pilot1/combined_rnaseq_data_$PREPROP_RNASEQ
export DRUG_REPSONSE_DATA=$BENCHMARKS_ROOT/Data/Pilot1/rescaled_combined_single_drug_growth

# TODO: move the following code to a utility library-
#       this is a configuration file
# Set the R data file for running
# if [ "$MODEL_NAME" = "combo" ]; then
#     PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/combo_hps_exp_01.R}
# elif [ "$MODEL_NAME" = "p1b1" ]; then
#     PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b1_hps_exp_01.R}
# elif [ "$MODEL_NAME" = "nt3" ]; then
#     PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/nt3_hps_exp_01.R}
# elif [ "$MODEL_NAME" = "p1b3" ]; then
#     PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b3_hps_exp_01.R}
# elif [ "$MODEL_NAME" = "p1b2" ]; then
#     PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p1b2_hps_exp_01.R}
# elif [ "$MODEL_NAME" = "p2b1" ]; then
#     PARAM_SET_FILE=${PARAM_SET_FILE:-$EMEWS_PROJECT_ROOT/data/p2b1_param1.R}
# fi

# Location of mlrMBO input file. uno_quick_test is
# appropriate for testing
PARAM_SET_FILE=$EMEWS_PROJECT_ROOT/data/uno_quick_test.R
# Actual useful mlrMBO input file for uno: uno_hpo.R 
# PARAM_SET_FILE=$EMEWS_PROJECT_ROOT/data/uno_hpo.R

if [[ "${PARAM_SET_FILE:-}" == "" ]]; then
  # PARAM_SET_FILE must be set before this script returns!
  echo "Invalid model-" "'${MODEL_NAME:-}'"
  exit 1
fi
