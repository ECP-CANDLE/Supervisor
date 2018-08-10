
# async-search CFG SYS test-1

# The number of MPI processes
# Note that 2 processes are reserved for Swift/EMEMS
# The default of 4 gives you 2 workers, i.e., 2 concurrent Keras runs
export PROCS=${PROCS:-256}

# MPI processes per node
# Cori has 32 cores per node, 128GB per node
export PPN=${PPN:-1}

# For Theta:
# export QUEUE=${QUEUE:-debug}

export WALLTIME=${WALLTIME:-06:00:00}

PYTHONPATH+=:$HOME/.local/cori/deeplearning2.7/lib/python2.7/site-packages
export PYTHONPATH

LD_LIBRARY_PATH+=/global/homes/w/wozniak/Public/sfw/R-3.4.0-gcc-7.1.0/lib64/R/lib:/global/homes/w/wozniak/Public/sfw/R-3.4.0-gcc-7.1.0/lib64/R/library/RInside/lib

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
export SH_TIMEOUT=${SH_TIMEOUT:-3600}
