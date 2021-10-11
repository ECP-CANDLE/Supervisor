
# SCHED Spock

# Tell Swift/T to use SLURM:
MACHINE="-m slurm"
export TURBINE_LAUNCHER=srun

# Default CANDLE account settings for Spock:
export PROJECT=${PROJECT:-MED106}
export QUEUE=${QUEUE:-ecp}
