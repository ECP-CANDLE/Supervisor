
# CFG UNO TEST

# # For containers:
# export CANDLE_MODEL_TYPE="SINGULARITY"
# export MODEL_NAME=/software/improve/images/Uno_Improve.sif  #Lambda

# For plain Python:
export MODEL_NAME=uno
export MODEL_PYTHON_DIR=$HOME/proj/IMPROVE-Benchmarks/Pilot1/Uno

export PARAM_SET_FILE=uno_param_space-1.json

export FRAMEWORK="keras"

# SMALL:
export PROCS=4
export POPULATION_SIZE=4
export NUM_ITERATIONS=3

# # MEDIUM:
# export PROCS=4
# export POPULATION_SIZE=16
# export NUM_ITERATIONS=4

# # LARGE:
# export PROCS=12
# export POPULATION_SIZE=80
# export NUM_ITERATIONS=10
