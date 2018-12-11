
# LANGS Titan
# Language settings for Titan (Swift, Python, R, Tcl, etc.)

SWIFT_IMPL=app

export R=/sw/xk6/r/3.3.2/sles11.3_gnu4.9.3x/lib64/R
export PY=/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3
export LD_LIBRARY_PATH=$PY/lib:$R/lib:$LD_LIBRARY_PATH

# We do not export PYTHONPATH or PYTHONHOME
# We pass them through swift-t -e, which exports them later
# This is to avoid misconfiguring Python on the login node
# (especially for Cobalt)
PYTHONHOME=/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3

LD_LIBRARY_PATH=/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/lib:/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/cuda/lib64:/opt/gcc/4.9.3/snos/lib64:/sw/xk6/r/3.3.2/sles11.3_gnu4.9.3x/lib64/R/lib

# export PATH=/lustre/atlas2/csc249/proj-shared/sfw/swift-t/stc/bin:$PATH
export PATH=/lustre/atlas2/med106/world-shared/sfw/titan/compute/swift-t/2018-11-29/stc/bin:$PATH
# TCL=/lustre/atlas2/med106/world-shared/sfw/titan/compute/tcl-8.6.6

# EMEWS Queues for R
EQR=/lustre/atlas2/csc249/proj-shared/sfw/EQ-R
EQPy=$WORKFLOWS_ROOT/common/ext/EQ-Py

# For test output processing:
LOCAL=0
CRAY=1

# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

log_path PYTHONPATH
