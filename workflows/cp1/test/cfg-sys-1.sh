
# MLRMBO CFG SYS 1

# The total number of MPI processes including 2
# for swift internals, and the number of 
# mlrMBO instances and the number of individual
# Uno HPO runs.
export PROCS=${PROCS:-6}

# Number of processes to use for resident tasks,
# i.e., the number of mlrMBO instances to run
# This needs to equal the number of cross correlated
# feature input files to be run
export TURBINE_RESIDENT_WORK_WORKERS=4

# MPI processes per node
export PPN=${PPN:-1}

# For Theta:
export QUEUE=${QUEUE:-debug-flat-quad}
# export QUEUE=R.candle

export WALLTIME=${WALLTIME:-00:10:00}

# Comma separated list of gpu ids
# Uncomment and edit appropriately
# if your HPC resource has multiple GPUS
# export GPU_STRING=${GPU_STRING:-0,1}
# Specify any MPI launcher (srun, bsub, etc.) options here.
#export TURBINE_LAUNCH_OPTIONS="-a6 -g6 -c42"
#export TURBINE_LAUNCH_OPTIONS="-g6 -c42 -a1 -b packed:42"

#export PROJECT=Candle_ECP

# Benchmark run timeout: benchmark run will timeout
# after the specified number of seconds.
# If set to -1 there is no timeout.
# This timeout is implemented with Keras callbacks
BENCHMARK_TIMEOUT=${BENCHMARK_TIMEOUT:-3600}

# Uncomment below to use custom python script to run
# Use file name without .py (e.g, my_script.py)
# MODEL_PYTHON_SCRIPT=my_script

# Shell timeout: benchmark run will be killed
# after the specified number of seconds.
# If set to -1 or empty there is no timeout.
# This timeout is implemented with the shell command 'timeout'
export SH_TIMEOUT=${SH_TIMEOUT:-}

# Ignore errors: If 1, unknown errors will be reported to model.log
# but will not bring down the Swift workflow.  See model.sh .
export IGNORE_ERRORS=0
