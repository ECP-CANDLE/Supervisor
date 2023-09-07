#
# GA CFG SYS 1

# The number of MPI processes
# Note that 2 processes are reserved for Swift/EMEMS
# The default of 4 gives you 2 workers, i.e., 2 concurrent Keras runs
export PROCS=${PROCS:-10}

# MPI processes per node
# Cori has 32 cores per node, 128GB per node
export PPN=${PPN:-10}

#  Benchmark run timeout: benchmark run will timeout
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

# if the deap python package is not installed with swift-t's embedded python
# it may be ncessary to include its location in the PYTHONPATH
# export PYTHONPATH=/global/u1/n/ncollier/.local/cori/deeplearning2.7/lib/python2.7/site-packages


# for running locally, edit as necessary
# export PYTHONHOME=$HOME/anaconda3
# export PYTHON=python3.6
# export SWIFT_T=$HOME/sfw/swift-t-4c8f0afd
