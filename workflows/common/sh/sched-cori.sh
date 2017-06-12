
# SCHED CORI
# Scheduler settings for Cori

# Tell Swift/T to generate and submit a SLURM script
MACHINE="-m slurm"

# This will be pasted into the SLURM script
export TURBINE_DIRECTIVE="#SBATCH --constraint=haswell\n#SBATCH --license=SCRATCH"

