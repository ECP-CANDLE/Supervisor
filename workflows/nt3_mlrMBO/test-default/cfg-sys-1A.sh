
# NT3 CFG SYS 1A

# The number of MPI processes
# Note that 2 processes are reserved for Swift/EMEMS
# The default of 4 gives you 2 workers, i.e., 2 concurrent Keras runs
export PROCS=${PROCS:-16}

# MPI processes per node
# Cori has 32 cores per node, 128GB per node
export PPN=${PPN:-4}

#export QUEUE=${QUEUE:-debug-flat-quad}
export WALLTIME=${WALLTIME:-00:59:00}

#export PROJECT=Candle_ECP
#export PROJECT=CSC249ADOA01

# Benchmark run timeout: benchmark run will timeouT
# after the specified number of seconds. -1 is no timeout.
BENCHMARK_TIMEOUT=${BENCHMARK_TIMEOUT:-1800}
