
# SCHED Summit TF2
# Scheduler settings for Swift/Summit

if (( ${INTERACTIVE:-0} ))
then
  # Interactive settings
  MACHINE=""
  export TURBINE_LAUNCHER=jsrun
else
  # Use LSF:
  MACHINE="-m lsf"
fi

# Default PROJECT for CANDLE
#export QUEUE=${QUEUE:-batch-hm}
export PROJECT=${PROJECT:-MED106}

# export TURBINE_OUTPUT_SOFTLINK=/dev/null
