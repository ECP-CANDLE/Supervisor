
# UPF CFG SYS 1

# The number of MPI processes
# Note that 1 processes is reserved for Swift/T
# For example, if PROCS=4 that gives you 3 workers,
# i.e., 3 concurrent Keras runs.
export PROCS=${PROCS:-2}

# MPI processes per node.  This should not exceed PROCS.
# Cori has 32 cores per node, 128GB per node
export PPN=${PPN:-1}

#export QUEUE=${QUEUE:-batch}

# Cori: (cf. sched-cori)
# export QUEUE=${QUEUE:-debug}
# export QUEUE=debug
# CANDLE on Cori:
# export PROJECT=m2924

# Theta: (cf. sched-theta)
export QUEUE=debug-cache-quad
export PROJECT=ecp-testbed-01
#export PROJECT=Candle_ECP
#export PROJECT=CSC249ADOA01

export WALLTIME=${WALLTIME:-00:10:00}

# Benchmark run timeout: benchmark run will timeouT
# after the specified number of seconds. -1 is no timeout.
BENCHMARK_TIMEOUT=${BENCHMARK_TIMEOUT:-3600}
