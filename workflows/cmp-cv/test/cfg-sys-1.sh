
# CMP-CV CFG SYS 1

# Use 1 for interactive workflows
# export INTERACTIVE=1

# The number of MPI processes
# Note that 1 process is reserved for Swift/T
# For example, if PROCS=4 that gives you 3 workers,
# i.e., 3 concurrent Keras runs.
export PROCS=${PROCS:-2}

# MPI processes per node.  This should not exceed PROCS.
# Cori has 32 cores per node, 128GB per node
export PPN=${PPN:-2}

#export QUEUE=${QUEUE:-batch}

export WALLTIME=${WALLTIME:-1:00:00}
echo WALLTIME: $WALLTIME

# export MAIL_ENABLED=1
# export MAIL_ADDRESS=woz@anl.gov

# Benchmark run timeout: benchmark run will timeouT
# after the specified number of seconds. -1 is no timeout.
BENCHMARK_TIMEOUT=${BENCHMARK_TIMEOUT:-3600}
