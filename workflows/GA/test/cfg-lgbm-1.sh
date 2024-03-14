
# CFG LGBM TEST

# For containers:
# export CANDLE_MODEL_TYPE="SINGULARITY"
# export MODEL_NAME=/software/improve/images/lgbm_0.6.0.sif  #Lambda

# For plain Python:
export MODEL_NAME=lgbm
export MODEL_PYTHON_DIR=$HOME/proj/LGBM

export PARAM_SET_FILE=lgbm_param_space-1.json

export FRAMEWORK="keras"

# SMALL:
export PROCS=6
export PPN=6
export POPULATION_SIZE=4
export NUM_ITERATIONS=3

# # MEDIUM:
# export PROCS=10
# export POPULATION_SIZE=16
# export NUM_ITERATIONS=4

# # LARGE:
# export PROCS=4
# export POPULATION_SIZE=80
# export NUM_ITERATIONS=10
