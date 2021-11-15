
# CP LEAVEOUT CFG SYS 512

# PROCS: The number of MPI processes
# Note that 1 process is reserved for Swift/T,
#      and  1 process is reserved for the DB client.
# The default of 4 gives you 2 workers,
#     i.e., 2 concurrent Keras runs.
# Bin 	Min Nodes 	Max Nodes 	Max Walltime (Hours) 	Aging Boost (Days)
# 1 	2,765 	4,608 	24.0 	15
# 2 	922 	2,764 	24.0 	10
# 3 	92 	921 	12.0 	0
# 4 	46 	91 	6.0 	0
# 5 	1 	45 	2.0
export PROCS=${PROCS:-6}

# MPI processes per node
# Cori has 32 cores per node, 128GB per node
export PPN=${PPN:-1}

export WALLTIME=${WALLTIME:-12:00:00}

# command separated list of gpu ids
# export GPU_STRING=${GPU_STRING:-0}
#export TURBINE_LAUNCH_OPTIONS="-a6 -g6 -c42"

if (( PPN == 1 ))
then
  export TURBINE_LAUNCH_OPTIONS="-g6 -c42 -a1 -b packed:42"
else
  # For PPN=4 debugging:
  export TURBINE_LAUNCH_OPTIONS="-g1 -c7 -a1"
fi

if [[ $SITE == "summit" ]]
then
  export TURBINE_DIRECTIVE="#BSUB -alloc_flags \"NVME maximizegpfs\""
fi

#export PROJECT=Candle_ECP

# Benchmark run timeout: benchmark run will timeout
# after the specified number of seconds.
# If set to -1 there is no timeout.
# This timeout is implemented with Keras callbacks
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
