
# SCHED Aurora

# Scheduler settings for Swift/T/PBS/Aurora

MACHINE="-m pbs"

# Default PROJECT for CANDLE
export PROJECT=${PROJECT:-candle_aesp_CNDA}
export QUEUE=${QUEUE:-debug}
export WALLTIME=${WALLTIME:-00:10:00}

# See https://docs.alcf.anl.gov/aurora/running-jobs-aurora/#submitting-a-job
export TURBINE_DIRECTIVE="#PBS -l filesystems=flare"
