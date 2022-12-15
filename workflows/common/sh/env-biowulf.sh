#!/bin/bash

# Note: It probably would make most sense to source site-specific_settings.sh here and then to use below the variables set in that file
# Prerequisite: Assume the candle module is loaded as usual
# This is a second test comment line


#### Set variables for CANDLE dependencies (mostly, Swift/T dependencies) ##########################################################
# This is for building CANDLE/Swift/T but it doesn't hurt to set these always
export CANDLE_DEP_MPI="/usr/local/OpenMPI/4.0.4/CUDA-10.2/gcc-9.2.0"
export CANDLE_DEP_TCL="/data/BIDS-HPC/public/software/builds/tcl"
export CANDLE_DEP_PY="/usr/local/Anaconda/envs/py3.7"
export CANDLE_DEP_R="/usr/local/apps/R/4.0/4.0.0/lib64/R"
export CANDLE_DEP_R_SITE="/usr/local/apps/R/4.0/site-library_4.0.0"
export CANDLE_DEP_ANT="/usr/local/apps/ant/1.10.3"
export CANDLE_LAUNCHER_OPTION="--with-launcher=/usr/local/slurm/bin/srun"
####################################################################################################################################


#### Load the stack ################################################################################################################
# Load the lmod environment modules
module load gcc/9.2.0 openmpi/4.0.4/cuda-10.2/gcc-9.2.0 ant/1.10.3 java/1.8.0_211 pcre2/10.21 GSL/2.6_gcc-9.2.0

# Load the Tcl we built on 9/12/20
export PATH="/data/BIDS-HPC/public/software/builds/tcl/bin:$PATH"
export LD_LIBRARY_PATH="/data/BIDS-HPC/public/software/builds/tcl/lib:$LD_LIBRARY_PATH"
export MANPATH="/data/BIDS-HPC/public/software/builds/tcl/man:$MANPATH"

# Load R/4.0.0 paths manually since we can't load the module on the Biowulf submit nodes (part of new stack on 8/13/20)
export PATH="$PATH:/usr/local/apps/R/4.0/4.0.0/bin"
export LIBRARY_PATH="$LIBRARY_PATH:/usr/local/intel/compilers_and_libraries_2019.1.144/linux/mkl/lib/intel64"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/intel/compilers_and_libraries_2019.1.144/linux/mkl/lib/intel64"
if [ -z ${R_LIBS_USER+x} ]; then
    R_LIBS_USER="$HOME/R/%v/library"
else
    R_LIBS_USER="$R_LIBS_USER:$HOME/R/%v/library"
fi
export R_LIBS_SITE="$CANDLE_DEP_R_SITE"
export R_LIBS="$CANDLE/R/libs"
####################################################################################################################################


#### Swift/T/MPI setup #############################################################################################################
# Basic Swift/T settings
export SWIFT_T_INSTALL="$CANDLE/swift-t-install"
export PATH="$PATH:$SWIFT_T_INSTALL/stc/bin"
export PATH="$PATH:$SWIFT_T_INSTALL/turbine/bin"
export PYTHONPATH="$PYTHONPATH:$SWIFT_T_INSTALL/turbine/py"
export TURBINE_HOME="$SWIFT_T_INSTALL/turbine"
export TURBINE_LOG="1"
export ADLB_DEBUG_RANKS="1"
export ADLB_DEBUG_HOSTMAP="1"
export SWIFT_IMPL="app"

# Resident task workers and ranks
if [ -z ${TURBINE_RESIDENT_WORK_WORKERS+x} ]; then # if $TURBINE_RESIDENT_WORK_WORKERS is unset...
    export TURBINE_RESIDENT_WORK_WORKERS="1"
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi

# Set up EMEWS Queues
export EQR="$CANDLE/Supervisor/workflows/common/ext/EQ-R"
export EQPy="$CANDLE/Supervisor/workflows/common/ext/EQ-Py"

# This is how Tim Miller told me to run interactive and batch MPI jobs on Biowulf GPU nodes recently (Aug/Sep 2020)
if [ "x${SLURM_JOB_PARTITION:-batch}" == "xinteractive" ]; then
    export TURBINE_LAUNCH_OPTIONS+=" --mpi=pmix --mem=0"
else
    export TURBINE_LAUNCH_OPTIONS+=" --mpi=pmix"
fi

# This prevents PMIx errors I believe
export TURBINE_MPI_THREAD=0 # only currently used in Supervisor/workflows/upf/swift/workflow.sh
####################################################################################################################################


#### Miscellaneous settings/output #################################################################################################
# Add the Supervisor workflows scripts to the Python path
export PYTHONPATH="$PYTHONPATH:$CANDLE/Supervisor/workflows/common/python"

# Log settings to output
command -v python || echo "WARNING: Program 'python' not found"
command -v swift-t || echo "WARNING: Program 'swift-t' not found"
####################################################################################################################################
