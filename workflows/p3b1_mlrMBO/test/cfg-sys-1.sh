
# CFG SYS 1
# Configuration of system: 1
# The original system settings

# The number of MPI processes
# Note that 2 processes are reserved for Swift/EMEMS
# The default of 4 gives you 2 workers, i.e., 2 concurrent Keras runs
export PROCS=${PROCS:-4}

# MPI processes per node
# Cori has 32 cores per node, 128GB per node
export PPN=${PPN:-4}
export QUEUE=${QUEUE:-debug}
export WALLTIME=${WALLTIME:-00:03:00}
