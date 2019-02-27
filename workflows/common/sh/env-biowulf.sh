# LANGS BIOWULF
# Language settings for non-Singularity Biowulf (Python, R, etc.)
# Assumes WORKFLOWS_ROOT is set

# Modules; this and following R block are what was needed to successfully at least COMPILE Swift/T
module load gcc/7.3.0 openmpi/3.1.2/cuda-9.0/gcc-7.3.0-pmi2 tcl_tk/8.6.8_gcc-7.2.0 python/3.6 ant/1.10.3 java/1.8.0_181

# Load R paths manually since we can't load the module on the Biowulf submit nodes
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/GSL/gcc-7.2.0/2.4/lib:/usr/local/geos/3.6.2/lib:/usr/local/intel/compilers_and_libraries_2018.1.163/linux/mkl/lib/intel64
PATH=$PATH:/usr/local/GSL/gcc-7.2.0/2.4/bin:/usr/local/apps/R/3.5/3.5.0_build2/bin
export R_LIBS_SITE=/usr/local/apps/R/3.5/site-library_build2
export R_LIBS_USER=~/R/%v/library

# Which line is uncommented depends on which GPU system we’re using, e.g., k20x needs the first line uncommented, and p100 and v100’s need the second line uncommented. This suppresses an MPI error due to having multiple Infiniband interfaces.
#export OMPI_MCA_btl_openib_if_exclude="mlx4_0:1"
#export OMPI_MCA_btl_openib_if_exclude="mlx4_0:2"

# Other additions
CANDLE=/data/BIDS-HPC/public/candle
export R_LIBS=$CANDLE/R/libs/ # these are the libraries I installed via workflows/common/R/install-candle.sh
export PATH=$PATH:$CANDLE/swift-t-install/stc/bin
export PATH=$PATH:$CANDLE/swift-t-install/turbine/bin
export TURBINE_LOG=1
export ADLB_DEBUG_RANKS=1
export ADLB_DEBUG_HOSTMAP=1
export LD_PRELOAD=/usr/local/slurm/lib/libslurm.so # this is the only way aside from recompiling Swift/T I believe to get past an error regarding /usr/local/slurm/lib/slurm/auth_munge.so
export EQR=$WORKFLOWS_ROOT/common/ext/EQ-R # I don’t know where else to find this directory that needs to be available, e.g., in workflow.sh
PYTHONPATH=${PYTHONPATH:-}:$CANDLE/swift-t-install/turbine/py

# Set up environment
#module load python/3.6
#module load openmpi/3.0.0/gcc-7.2.0-pmi2
#### NOTE I'M COMMENTING THIS OUT SINCE IT WON'T LOAD ON SUBMIT NODE!!!! ####module load R/3.5.0
#export R_LIBS=$CANDLE/R/libs/
#export PATH=${PATH}:$CANDLE/swift-t-install/turbine/bin
#export PATH=${PATH}:$CANDLE/swift-t-install/stc/bin
#export PROCS=3
#export PPN=1
#export SLURM_MPI_TYPE=mpi/openmpi
#export SLURM_MPI_TYPE=pmi2

# Options for SLURM_MPI_TYPE on Biowulf:
#weismanal@biowulf:/usr/local/slurm/etc $ srun --mpi=list
#srun: MPI types are...
#srun: mpi/mpich1_p4
#srun: mpi/mpich1_shmem
#srun: mpi/mpichgm
#srun: mpi/mpichmx
#srun: mpi/mvapich
#srun: mpi/none
#srun: mpi/lam
#srun: mpi/openmpi
#srun: mpi/pmi2

# Swift/T
#SWIFT=/global/homes/w/wozniak/Public/sfw/compute/swift-t-2018-06-05
#export PATH=$SWIFT/stc/bin:$PATH
# On Cori, we have a good Swift/T Python embedded interpreter,
# but we use app anyway
SWIFT_IMPL="app"

# Python
#PYTHON=/global/common/cori/software/python/2.7-anaconda/envs/deeplearning
#export PATH=$PYTHON/bin:$PATH
#PYTHON=$(which python) # THIS BREAKS THINGS SO I ANDREW AM COMMENTING IT OUT!!! (encoding error when trying to load python)... and adding following line
PYTHON=$(cd $(dirname $(which python))/../; pwd)
PYTHONPATH=${PYTHONPATH:-}${PYTHONPATH:+:}
PYTHONPATH+=$EMEWS_PROJECT_ROOT/python:
#PYTHONPATH+=$BENCHMARK_DIR:
#PYTHONPATH+=$BENCHMARKS_ROOT/common:
#PYTHONPATH+=$SWIFT/turbine/py:
COMMON_DIR=$WORKFLOWS_ROOT/common/python
PYTHONPATH+=$COMMON_DIR
export PYTHONPATH
export PYTHONHOME=$PYTHON

# R
#export R_HOME=/global/homes/w/wozniak/Public/sfw/R-3.4.0-gcc-7.1.0/lib64/R

# EMEWS Queues for R
#EQR=/global/homes/w/wozniak/Public/sfw/compute/EQ-R
EQPy=$WORKFLOWS_ROOT/common/ext/EQ-Py

# Resident task workers and ranks
if [ -z ${TURBINE_RESIDENT_WORK_WORKERS+x} ]
then
    # Resident task workers and ranks
    export TURBINE_RESIDENT_WORK_WORKERS=1
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi

echo "RESIDENT_WORK_RANKS=$RESIDENT_WORK_RANKS"

# LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}${LD_LIBRARY_PATH:+:}
#LD_LIBRARY_PATH+=$R_HOME/lib

# Log settings to output
which python swift-t
# Cf. utils.sh
# show     PYTHONHOME
# log_path LD_LIBRARY_PATH
# log_path PYTHONPATH
