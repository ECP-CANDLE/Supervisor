
# Scheduler settings for Swift/Summit

MACHINE="-m lsf"

# Default PROJECT for CANDLE
#export QUEUE=${QUEUE:-batch-hm}
export PROJECT=${PROJECT:-MED106}

# export TURBINE_OUTPUT_SOFTLINK=/dev/null

JSRUN_DEFAULT="-a1 -g6 -c7"

if (( PPN == 1 ))
then
  export TURBINE_LAUNCH_OPTIONS="-g6 -c42 -a1 -b packed:42"
else
  # For PPN=4 debugging:
  export TURBINE_LAUNCH_OPTIONS="-g1 -c7 -a1"
fi

export TURBINE_DIRECTIVE="#BSUB -alloc_flags \"NVME maximizegpfs\""
