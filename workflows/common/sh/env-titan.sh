SWIFT_IMPL=app
export R=/ccs/proj/med106/gounley1/titan/R-3.2.1/lib64/R
export PY=/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3
export LD_LIBRARY_PATH=$PY/lib:$R/lib:$LD_LIBRARY_PATH
# We do not export PYTHONPATH or PYTHONHOME
# We pass them through swift-t -e, which exports them later
# This is to avoid misconfiguring Python on the login node
# (especially for Cobalt)
PYTHONHOME=/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3
LD_LIBRARY_PATH=/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/lib:/sw/xk6/deeplearning/1.0/sles11.3_gnu4.9.3/cuda/lib64:/opt/gcc/6.3.0/snos/lib64:/ccs/proj/med106/gounley1/titan/R-3.2.1/lib64/R/lib
# export PATH=/lustre/atlas2/csc249/proj-shared/sfw/swift-t/stc/bin:$PATH
export PATH=/lustre/atlas2/med106/world-shared/sfw/titan/compute/swift-t/2018-12-12/stc/bin:$PATH
# TCL=/lustre/atlas2/med106/world-shared/sfw/titan/compute/tcl-8.6.6
# EMEWS Queues for R
EQR=/lustre/atlas2/med106/proj-shared/gounley1/titan/EQ-R
EQPy=$WORKFLOWS_ROOT/common/ext/EQ-Py
# For test output processing:
LOCAL=0
CRAY=1
# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
log_path PYTHONPATH
