# CFG PRM 1


# Directory ocation of the pregenerated train and test data frames (e.g CTRP_CCLE_2000_1000_train.h5)
CACHE_DIR=$EMEWS_PROJECT_ROOT/cache
# Directory location of cross correlation feature files (e.g. CCLE_GDSC_2000_1000_features.txt)
XCORR_DATA_DIR=$EMEWS_PROJECT_ROOT/xcorr_data
# Location of the input file that contains the parameters for each
# inference run, 1 per row
UPF_FILE=$EMEWS_PROJECT_ROOT/data/infer_upf.txt
# Number of predictions to make for each inference runs
N_PRED=30
