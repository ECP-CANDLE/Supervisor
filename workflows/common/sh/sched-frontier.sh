
# SCHED Frontier

# Scheduler settings for Swift/T/SLURM/Frontier

MACHINE="-m slurm"

# Default PROJECT for CANDLE
#export QUEUE=${QUEUE:-batch}
export PROJECT=${PROJECT:-MED106}

export TURBINE_PRELAUNCH="source activate /gpfs/alpine/med106/proj-shared/hm0/candle_tf_2.10"
