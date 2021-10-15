
# Scheduler settings for Swift/Summit

MACHINE="-m lsf"

# Default PROJECT for CANDLE
#export QUEUE=${QUEUE:-batch-hm}
export PROJECT=${PROJECT:-MED106}

# export TURBINE_OUTPUT_SOFTLINK=/dev/null

JSRUN_DEFAULT="-a1 -g6 -c7"
export TURBINE_LAUNCH_OPTIONS=${TURBINE_LAUNCH_OPTIONS:-${JSRUN_DEFAULT}}
