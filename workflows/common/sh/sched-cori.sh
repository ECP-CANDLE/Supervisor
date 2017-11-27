
# SCHED CORI
# Scheduler settings for Swift/Cori

# Tell Swift/T to generate and submit a SLURM script
MACHINE="-m slurm"

# This will be pasted into the SLURM script
# export TURBINE_DIRECTIVE="#SBATCH -C knl,quad,cache\n#SBATCH --license=SCRATCH"
export TURBINE_DIRECTIVE="#SBATCH --constraint=haswell\n#SBATCH --license=SCRATCH"
