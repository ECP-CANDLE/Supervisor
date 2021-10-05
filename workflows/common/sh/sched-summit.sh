
# Scheduler settings for Swift/Summit

MACHINE="-m lsf"

# Default PROJECT for CANDLE
#export QUEUE=${QUEUE:-batch-hm}
export PROJECT=${PROJECT:-MED106}

# export TURBINE_OUTPUT_SOFTLINK=/dev/null

export TURBINE_LAUNCH_OPTIONS="-a1 -g6 -c7"
