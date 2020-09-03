
# CP LEAVEOUT CFG SYS 1

# The number of MPI processes
# Note that 2 processes are reserved for Swift/EMEMS
# The default of 4 gives you 2 workers, i.e., 2 concurrent Keras runs
export PROCS=${PROCS:-12}
# export PROCS=${PROCS:-128}

# MPI processes per node
# Cori has 32 cores per node, 128GB per node
export PPN=${PPN:-6}

# For Theta:
#export QUEUE=${QUEUE:-batch-hm}
# export QUEUE=R.candle

export WALLTIME=${WALLTIME:-02:00:00}

# command separated list of gpu ids
# export GPU_STRING=${GPU_STRING:-0}
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
