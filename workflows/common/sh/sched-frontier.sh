
# SCHED Frontier

# Scheduler settings for Swift/T/SLURM/Frontier

MACHINE="-m slurm"

# Default PROJECT for CANDLE
#export QUEUE=${QUEUE:-batch}
export PROJECT=${PROJECT:-MED106}

# PY=/gpfs/alpine/med106/proj-shared/hm0/candle_tf_2.10
PY=/lustre/orion/world-shared/med106/gounley1/conda543
MODS=( DefApps
       ums
       ums002
       # craype/2.7.21
       # cpe/23.05
       # PrgEnv-gnu/8.4.0
       cray-mpich )
export TURBINE_PRELAUNCH="module load ${MODS[@]} ; source activate $PY"

export TURBINE_DIRECTIVE="#SBATCH -C nvme"

export TURBINE_LAUNCH_OPTIONS="--gpus-per-task=1 --gpus-per-node=$PPN"
