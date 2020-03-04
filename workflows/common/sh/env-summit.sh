
# ENV Summit
# Environment settings for Summit (Swift, Python, R, Tcl, etc.)

# SWIFT_IMPL=app
# SWIFT_IMPL=echo
SWIFT_IMPL=py

# Load basic LD_LIBRARY_PATH before changing it:
# module load gcc/4.8.5
# module load gcc/6.4.0
module load gcc/7.4.0
module load spectrum-mpi/10.3.0.1-20190611
module load ibm-wml-ce
module unload darshan-runtime

module list

# log_path PATH

# ROOT=/ccs/proj/med106/gounley1/summit

# export PY=$ROOT/miniconda37
# export R=$ROOT/R-190814/lib64/R/lib

# export LD_LIBRARY_PATH=$PY/lib:$R:$LD_LIBRARY_PATH

# SWIFT=$ROOT/swift-t-190822
# PATH=$SWIFT/stc/bin:$PATH

# From Wozniak
MED106=/gpfs/alpine/world-shared/med106
# SWIFT=$MED106/gcc-6.4.0/swift-t/2019-07-10
# SWIFT=$MED106/gcc-6.4.0/swift-t/2019-10-02
# SWIFT=$MED106/sw/gcc-4.8.5/swift-t/2019-10-08  # Python, no R
# SWIFT=$MED106/sw/gcc-4.8.5/swift-t/2019-10-14  # Python and R
# SWIFT=$MED106/sw/gcc-4.8.5/swift-t/2019-10-14b # Python and R
# SWIFT=$MED106/sw/gcc-7.4.0/swift-t/2019-10-15    # Python, no R
# SWIFT=$MED106/sw/gcc-7.4.0/swift-t/2019-10-18  # Python (ibm-wml), no R
SWIFT=$MED106/gounley1/sandbox/swift-t-200304  # Python (ibm-wml) and R

PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH

# log_path PATH

# We do not export PYTHONPATH or PYTHONHOME
# We pass them through swift-t -e, which exports them later
# This is to avoid misconfiguring Python on the login node
PY=$MED106/gounley1/sandbox/.envs
PYTHONHOME=$PY
PYTHONPATH=${PYTHONPATH:-}${PYTHONPATH:+:}${SWIFT}/turbine/py
export PYTHONUSERBASE=$MED106/gounley1/sandbox/.envs

R=/gpfs/alpine/world-shared/med106/gounley1/sandbox/R-200304

export LD_LIBRARY_PATH
LD_LIBRARY_PATH+=:$PY/lib
LD_LIBRARY_PATH+=:$R/lib64/R/lib

# This is needed so Python can configure itself
PATH=$PY/bin:$PATH

# EMEWS Queues for R
EQR=/gpfs/alpine/world-shared/med106/gounley1/sandbox/EQ-R-200304
EQPy=$WORKFLOWS_ROOT/common/ext/EQ-Py

# For test output processing:
LOCAL=0
CRAY=1

# Resident task workers and ranks
if [ -z ${TURBINE_RESIDENT_WORK_WORKERS+x} ]
then
    # Resident task workers and ranks
    export TURBINE_RESIDENT_WORK_WORKERS=1
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi

# log_path PYTHONPATH
