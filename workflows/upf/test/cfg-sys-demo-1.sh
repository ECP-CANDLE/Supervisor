
# CFG SYS DEMO 1


# The number of MPI processes
# Note that 1 process is reserved for Swift/T
# For example, if PROCS=4 that gives you 3 workers,
# i.e., 3 concurrent Keras runs.
export PROCS=${PROCS:-6}

# MPI processes per node.  This should not exceed PROCS.
export PPN=${PPN:-6}

# Summit:
export QUEUE=${QUEUE:-batch}
export PROJECT=med106
export TURBINE_LAUNCH_OPTIONS="-a1 -g1 -c7"

# export WALLTIME=${WALLTIME:-0:30}

# Benchmark run timeout: benchmark run will timeouT
# after the specified number of seconds. -1 is no timeout.
BENCHMARK_TIMEOUT=${BENCHMARK_TIMEOUT:-3600}
