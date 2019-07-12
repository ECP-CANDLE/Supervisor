# LANGS APP SUMMIT SH

# WIP 2019-02-28

APP_PYTHONPATH=${APP_PYTHONPATH:-}

# Clear anything set by the system or Swift/T environment
unset PYTHONPATH
unset LD_LIBRARY_PATH

module load gcc/6.4.0
module load spectrum-mpi
module load cuda/9.2.148

module list

log_path PATH
log_path LD_LIBRARY_PATH

export PATH=/gpfs/alpine/world-shared/med106/miniconda3/bin:$PATH
export LD_LIBRARY_PATH=/gpfs/alpine/world-shared/med106/miniconda3/lib:$LD_LIBRARY_PATH

echo LANGS APP
set -x

which python3
log_path PATH
log_path LD_LIBRARY_PATH
python3 -c "print('HI')"
set +x
