
# UPF CFG SYS 1

# The number of MPI processes
# Note that 1 processes is reserved for Swift/T
# For example, if PROCS=4 that gives you 3 workers,
# i.e., 3 concurrent Keras runs.
export PROCS=${PROCS:-12}

# MPI processes per node.  This should not exceed PROCS.
export PPN=${PPN:-1}

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
export IGNORE_ERRORS=${IGNORE_ERRORS:-0}

# job walltime
export WALLTIME=${WALLTIME:-02:00:00}

# queue
export QUEUE=killable

# += is necessary here as the job dependency args are 
# set via TURBINE_DIRECTIVE
TURBINE_DIRECTIVE="\n#BSUB -q $QUEUE\n#BSUB -alloc_flags \"NVME maximizegpfs\"\n" 
export TURBINE_DIRECTIVE+=${TURBINE_DIRECTIVE_ARGS:-}

TURBINE_LAUNCH_OPTIONS="-a1 -c42 -g1 "
export TURBINE_LAUNCH_OPTIONS+=${TURBINE_LAUNCH_ARGS:-}

# Dry Run uses this to print out the stage config
# for each stage
echo "Resovled Stage Configuration:"
echo "   PROCS: $PROCS"
echo "   PPN: $PPN"
echo "   WALLTIME: $WALLTIME"
echo "   TURBINE_DIRECTIVE: $TURBINE_DIRECTIVE"
echo "   TURBINE_LAUNCH_OPTIONS: $TURBINE_LAUNCH_OPTIONS"
echo "   BENCHMARK_TIMEOUT: $BENCHMARK_TIMEOUT"
echo "   SH_TIMEOUT: $SH_TIMEOUT"
echo "   IGNORE_ERRORS: $IGNORE_ERRORS"


# export MAIL_ENABLED=1
# export MAIL_ADDRESS=wozniak@mcs.anl.gov

