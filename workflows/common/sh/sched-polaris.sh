
# SCHED Summit

# Scheduler settings for Swift/T/PBS/Polaris

MACHINE="-m pbs"

# Default PROJECT for CANDLE
export PROJECT=${PROJECT:-CSC249ADOA01}

export QUEUE=${QUEUE:-debug}
export WALLTIME=${WALLTIME:-00:10:00}

# These are Polaris-specific settings - see:
# https://www.alcf.anl.gov/support/user-guides/polaris/hardware-overview/machine-overview
# http://swift-lang.github.io/swift-t/sites.html#_polaris
export TURBINE_POLARIS=1
export TURBINE_DIRECTIVE='#PBS -l filesystems=home:grand'
