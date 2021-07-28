
# ENV Summit - TF 2.4.1
# Environment settings for Summit (Swift, Python, R, Tcl, etc.)

# SWIFT_IMPL=echo
SWIFT_IMPL=py

# Let modules initialize LD_LIBRARY_PATH before changing it:
set +eu # modules create errors outside our control
module load   spectrum-mpi/10.3.1.2-20200121
module unload darshan-runtime
module load   gcc/7.4.0
module list
set -eu

# Base project directory
MED106=/gpfs/alpine/world-shared/med106

# Swift/T location
SWIFT=$MED106/sw/gcc-7.4.0/swift-t/2021-07-28
export TURBINE_HOME=$SWIFT/turbine
PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH

# R settings
R=$MED106/wozniak/sw/gcc-6.4.0/R-3.6.1/lib64/R
LD_LIBRARY_PATH+=:$R/lib
# EMEWS Queues for R
EQR=$MED106/wozniak/sw/gcc-6.4.0/EQ-R

# For test output processing:
LOCAL=0
CRAY=1

# Resident task worker count and rank list
# If this is already set, we respect the user settings
# If this is unset, we set it to 1
#    and run the algorithm on the 2nd highest rank
# This value is only read in HPO workflows
if [[ ${TURBINE_RESIDENT_WORK_WORKERS:-} == "" ]]
then
    export TURBINE_RESIDENT_WORK_WORKERS=1
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi
