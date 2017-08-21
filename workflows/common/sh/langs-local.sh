export PY=/usr/lib/python2.7/
# export PATH=$PATH
export LD_LIBRARY_PATH=/home/jain/install/mpich-3.2/lib:/home/jain/install/jasper/lib:/home/jain/install/netcdf/lib:/home/jain/install/hdf5/lib:/home/jain/install/stc/lib:/home/jain/install/turbine/lib/:/home/jain/install/lb/lib:/home/jain/install/cutils/lib

COMMON_DIR=$EMEWS_PROJECT_ROOT/../common/python
PYTHONPATH=$EMEWS_PROJECT_ROOT/python:$BENCHMARK_DIR:$COMMON_DIR
PYTHONHOME=$PY




EQR=/home/jain/CANDLE/Supervisor/workflows/p1b1_mlrMBO/ext/EQ-R
SWIFT_IMPL="app"

# Log settings to output
echo "Programs:"
which python swift-t | nl

# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))

# Cf. utils.sh
show     PYTHONHOME
log_path LD_LIBRARY_PATH
log_path PYTHONPATH
