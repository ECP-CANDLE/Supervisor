
# CFG GraphDRP TEST

# export CANDLE_MODEL_TYPE="SINGULARITY"
# export MODEL_NAME=/software/improve/images/GraphDRP.sif  #Lambda

export MODEL_NAME=graphdrp
export MODEL_PYTHON_DIR=$HOME/proj/GraphDRP
export MODEL_RETURN=val_loss

export PARAM_SET_FILE=graphdrp_param_space-3.json

export CANDLE_FRAMEWORK="pytorch"

# SMALL:
export PROCS=3
export PPN=2
export POPULATION_SIZE=4
export NUM_ITERATIONS=3
export WALLTIME=00:05:00
export QUEUE=${QUEUE:-debug}

# # MEDIUM:
# export PROCS=16
# export PPN=4
# export POPULATION_SIZE=32
# export NUM_ITERATIONS=4
# export WALLTIME=00:20:00
# export QUEUE=${QUEUE:-debug}

# # LARGE:
# export PROCS=400
# export PPN=4
# export POPULATION_SIZE=80
# export NUM_ITERATIONS=10
# export WALLTIME=24:00:00
# export QUEUE=${QUEUE:-debug-scaling}

export PYTHONPATH=$HOME/proj/IMPROVE
export CANDLE_DATA_DIR=/eagle/Candle_ECP/wozniak/CDD
export PROJECT=IMPROVE

# Be sure to turn MPICH_GPU off!
export TURBINE_PRELAUNCH="
  module use /soft/modulefiles
  module load conda
  conda activate
  source /lus/eagle/projects/Candle_ECP/conda/venv-2024-04-30/bin/activate
  export MPICH_GPU_SUPPORT_ENABLED=0
"
