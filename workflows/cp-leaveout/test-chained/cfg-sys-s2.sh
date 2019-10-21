
# UPF CFG SYS 1

# The number of MPI processes
# Note that 1 processes is reserved for Swift/T
# For example, if PROCS=4 that gives you 3 workers,
# i.e., 3 concurrent Keras runs.
export PROCS=${PROCS:-18}

# MPI processes per node.  This should not exceed PROCS.
export TURBINE_LAUNCH_OPTIONS="-a1 -c42 -g1"
export PPN=${PPN:-1}

# Uncomment when one node per run
export TURBINE_DIRECTIVE+="\n#BSUB -alloc_flags \"NVME maximizegpfs\"\n"   

#export QUEUE=${QUEUE:-batch}

# Cori: (cf. sched-cori)
# export QUEUE=${QUEUE:-debug}
# Cori queues: debug, regular
# export QUEUE=regular
# export QUEUE=debug
# CANDLE on Cori:
# export PROJECT=m2924

# Theta: (cf. sched-theta)
# export QUEUE=${QUEUE:-debug-cache-quad}
# export PROJECT=${PROJECT:-ecp-testbed-01}
# export PROJECT=Candle_ECP
# export PROJECT=CSC249ADOA01

# Summit:
# export QUEUE=${QUEUE:-batch}
# export PROJECT=med106

# Benchmark run timeout: benchmark run will timeouT                                                                                             
# after the specified number of seconds. -1 is no timeout.  
BENCHMARK_TIMEOUT=${BENCHMARK_TIMEOUT:--1}

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


export WALLTIME=${WALLTIME:-01:00:00}

# export MAIL_ENABLED=1
# export MAIL_ADDRESS=wozniak@mcs.anl.gov
