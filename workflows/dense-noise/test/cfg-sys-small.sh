
# CFG SYS SMALL

# The number of MPI processes
# Note that 2 processes are reserved for Swift/EMEWS
# The default of 4 gives you 2 workers, i.e., 2 concurrent Keras runs
export PROCS=${PROCS:-2}

# MPI processes per node
export PPN=${PPN:-2}

export WALLTIME=${WALLTIME:-00:05:00}

# CANDLE@ALCF:
# export PROJECT=CSC249ADOA01
# export QUEUE="debug-scaling"

# CANDLE@OLCF:
export PROJECT=MED106
export QUEUE=batch

# Benchmark run timeout: benchmark run will timeout
# after the specified number of seconds.
# If set to -1 there is no timeout.
# This timeout is implemented with Keras callbacks
BENCHMARK_TIMEOUT=${BENCHMARK_TIMEOUT:-3600}

# Shell timeout: benchmark run will be killed
# after the specified number of seconds.
# If set to -1 or empty there is no timeout.
# This timeout is implemented with the shell command 'timeout'
export SH_TIMEOUT=${SH_TIMEOUT:-}

# Ignore errors: If 1, unknown errors will be reported to model.log
# but will not bring down the Swift workflow.  See model.sh .
export IGNORE_ERRORS=0

if [[ ${SITE} == "summit" ]]
then
  export TURBINE_LAUNCH_OPTIONS="-g6 -c42 -a1 -b packed:42"
fi
