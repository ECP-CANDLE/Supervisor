
# SCHED TITAN
# Scheduler settings for Swift/Titan

MACHINE="-m cray"

# Swift special setting for Titan
export TITAN=true

# Default PROJECT for CANDLE
export PROJECT=${PROJECT:-CSC249ADOA01}

# Option for CPU binding
# export TURBINE_LAUNCH_OPTIONS="-cc none"
