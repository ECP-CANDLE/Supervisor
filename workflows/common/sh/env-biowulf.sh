#!/bin/bash

# Assume the candle module is loaded as usual

# Load the environments for each MPI implementation
if [ "x$USE_OPENMPI" == "x1" ]; then # probably always use this on Biowulf as it's the best supported
    #module load gcc/7.3.0 openmpi/3.1.2/cuda-9.0/gcc-7.3.0-pmi2 tcl_tk/8.6.8_gcc-7.2.0 ant/1.10.3 java/1.8.0_181 # Note I had to stop using openmpi/3.1.2/cuda-9.0/gcc-7.3.0-pmi2 because at least as of 6/19/19 Biowulf seemed to stop supporting it (it was available only as a "hidden" module)
    #module load gcc/7.3.0 openmpi/3.1.3/cuda-9.2/gcc-7.3.0-pmi2 tcl_tk/8.6.8_gcc-7.2.0 ant/1.10.3 java/1.8.0_181
    module load gcc/9.2.0 openmpi/4.0.4/cuda-10.2/gcc-9.2.0 tcl_tk/8.6.8_gcc-7.2.0 ant/1.10.3 java/12.0.1 pcre2/10.21 GSL/2.6_gcc-9.2.0 # new stack on 8/14/20 - note, per my emails with Biowulf, they disabled development in PMI2 OpenMPI environments; further added pcre2/10.21 on 9/2/20 as otherwise installing Supervisor's R packages wouldn't work as R could not start at all; further added GSL/2.6_gcc-9.2.0 on 9/2/20 as otherwise the ggplot2 installation for Supervisor failed
    export OMPI_MCA_mpi_warn_on_fork=0
else
    module load tcl_tk/8.6.8_gcc-7.2.0 ant/1.10.3 java/1.8.0_181
    module remove openmpi/3.0.2/gcc-7.3.0
    module load gcc/7.2.0
    export LD_LIBRARY_PATH=/usr/local/slurm/lib:$LD_LIBRARY_PATH
    export PATH=/data/BIDS-HPC/public/software/builds/mpich-3.3-3/bin:$PATH
    export LD_LIBRARY_PATH=/data/BIDS-HPC/public/software/builds/mpich-3.3-3/lib:$LD_LIBRARY_PATH
    export LIBDIR=/data/BIDS-HPC/public/software/builds/mpich-3.3-3/lib:$LIBDIR
    export CPATH=/data/BIDS-HPC/public/software/builds/mpich-3.3-3/include:$CPATH
fi

# Load R/4.0.0 paths manually since we can't load the module on the Biowulf submit nodes (part of new stack on 8/13/20)
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/GSL/gcc-7.2.0/2.4/lib:/usr/local/geos/3.6.2/lib:/usr/local/intel/compilers_and_libraries_2018.1.163/linux/mkl/lib/intel64
#export PATH=$PATH:/usr/local/GSL/gcc-7.2.0/2.4/bin:/usr/local/apps/R/3.5/3.5.0_build2/bin
#export R_LIBS_SITE=/usr/local/apps/R/3.5/site-library_build2
#export R_LIBS_USER=~/R/%v/library
export PATH="$PATH:/usr/local/apps/R/4.0/4.0.0/bin"
export LIBRARY_PATH="$LIBRARY_PATH:/usr/local/intel/compilers_and_libraries_2019.1.144/linux/mkl/lib/intel64"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/intel/compilers_and_libraries_2019.1.144/linux/mkl/lib/intel64"
export R_LIBS_USER="$R_LIBS_USER:~/R/%v/library"
export R_LIBS_SITE="/usr/local/apps/R/4.0/site-library_4.0.0"
export R_LIBS="$CANDLE/R/libs"

# Swift/T setup
export SWIFT_T_INSTALL="$CANDLE/swift-t-install"
export PATH="$PATH:$SWIFT_T_INSTALL/stc/bin" # this is likely 1 of 2 lines needed to run swift-t out-of-the-box
export PATH="$PATH:$SWIFT_T_INSTALL/turbine/bin"
export PYTHONPATH="$PYTHONPATH:$SWIFT_T_INSTALL/turbine/py"
export TURBINE_HOME="$SWIFT_T_INSTALL/turbine"
export TURBINE_LOG="1"
export ADLB_DEBUG_RANKS="1"
export ADLB_DEBUG_HOSTMAP="1"
export SWIFT_IMPL="app"
# Resident task workers and ranks
if [ -z ${TURBINE_RESIDENT_WORK_WORKERS+x} ]; then
    export TURBINE_RESIDENT_WORK_WORKERS="1"
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi
# NOTE: Below is 2 of 2 lines needed to run swift-t out-of-the-box (no longer needed!!)
#export LD_PRELOAD=/usr/local/slurm/lib/libslurm.so:$LD_PRELOAD # this is the only way aside from recompiling Swift/T I believe to get past an error regarding /usr/local/slurm/lib/slurm/auth_munge.so, e.g., "/usr/local/Tcl_Tk/8.6.8/gcc_7.2.0/bin/tclsh8.6: symbol lookup error: /usr/local/slurm/lib/slurm/auth_munge.so: undefined symbol: slurm_debug"

# Set up EMEWS Queues
export EQR="$CANDLE/Supervisor/workflows/common/ext/EQ-R" # I don’t know where else to find this directory that needs to be available, e.g., in workflow.sh
export EQPy="$CANDLE/Supervisor/workflows/common/ext/EQ-Py"

# Other additions
export PYTHONPATH="$PYTHONPATH:$CANDLE/Supervisor/workflows/common/python"

# Log settings to output
command -v python || echo "WARNING: Program 'python' not found"
command -v swift-t || echo "WARNING: Program 'swift-t' not found"
