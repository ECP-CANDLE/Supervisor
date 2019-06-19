#!/bin/bash

# Set up Python variables below

# Assume the CANDLE variable is set

export SWIFT_T_INSTALL=$CANDLE/swift-t-install
export R_LIBS=$CANDLE/R/libs

module load tcl_tk/8.6.8_gcc-7.2.0 ant/1.10.3 java/1.8.0_181
module remove openmpi/3.0.2/gcc-7.3.0
module load gcc/7.2.0
export LD_LIBRARY_PATH=/usr/local/slurm/lib:$LD_LIBRARY_PATH
export PATH=/data/BIDS-HPC/public/software/builds/mpich-3.3-3/bin:$PATH
export LD_LIBRARY_PATH=/data/BIDS-HPC/public/software/builds/mpich-3.3-3/lib:$LD_LIBRARY_PATH
export LIBDIR=/data/BIDS-HPC/public/software/builds/mpich-3.3-3/lib:${LIBDIR:-}
export CPATH=/data/BIDS-HPC/public/software/builds/mpich-3.3-3/include:${CPATH:-}

# Load R paths manually since we can't load the module on the Biowulf submit nodes
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/GSL/gcc-7.2.0/2.4/lib:/usr/local/geos/3.6.2/lib:/usr/local/intel/compilers_and_libraries_2018.1.163/linux/mkl/lib/intel64
export PATH=$PATH:/usr/local/GSL/gcc-7.2.0/2.4/bin:/usr/local/apps/R/3.5/3.5.0_build2/bin
export R_LIBS_SITE=/usr/local/apps/R/3.5/site-library_build2
export R_LIBS_USER=~/R/%v/library

export PATH=$PATH:$CANDLE/swift-t-install/stc/bin
export PATH=$PATH:$CANDLE/swift-t-install/turbine/bin
export TURBINE_LOG=1
export ADLB_DEBUG_RANKS=1
export ADLB_DEBUG_HOSTMAP=1

# Other additions
#export LD_PRELOAD=/usr/local/slurm/lib/libslurm.so:${LD_PRELOAD:-} # this is the only way aside from recompiling Swift/T I believe to get past an error regarding /usr/local/slurm/lib/slurm/auth_munge.so
export EQR=$CANDLE/Supervisor/workflows/common/ext/EQ-R # I don’t know where else to find this directory that needs to be available, e.g., in workflow.sh
export PYTHONPATH=$CANDLE/swift-t-install/turbine/py

export SWIFT_IMPL="app"

export PYTHONPATH+=$CANDLE/Supervisor/workflows/common/python

# EMEWS Queues for R
export EQPy=$CANDLE/Supervisor/workflows/common/ext/EQ-Py

# Resident task workers and ranks
if [ -z ${TURBINE_RESIDENT_WORK_WORKERS+x} ]
then
    # Resident task workers and ranks
    export TURBINE_RESIDENT_WORK_WORKERS=1
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi

# Log settings to output
which python swift-t
