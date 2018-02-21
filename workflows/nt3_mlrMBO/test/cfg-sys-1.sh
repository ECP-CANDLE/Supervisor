
# NT3 CFG SYS 1

# The number of MPI processes
# Note that 2 processes are reserved for Swift/EMEMS
# For example, if PROCS=4 that gives you 2 workers,
# i.e., 2 concurrent Keras runs.
export PROCS=${PROCS:-32}

# MPI processes per node.  This should not exceed PROCS.
# Cori has 32 cores per node, 128GB per node
export PPN=${PPN:-1}

#export QUEUE=${QUEUE:-batch}
#export QUEUE=${QUEUE:-debug}
export WALLTIME=${WALLTIME:-00:30:00}

#export PROJECT=Candle_ECP
#export PROJECT=CSC249ADOA01
#export PROJECT=m2924

# Benchmark run timeout: benchmark run will timeouT
# after the specified number of seconds. -1 is no timeout.
BENCHMARK_TIMEOUT=${BENCHMARK_TIMEOUT:-3600}
