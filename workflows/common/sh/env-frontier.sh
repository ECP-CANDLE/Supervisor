
# ENV Frontier

# CANDLE_MODEL_IMPL=echo
CANDLE_MODEL_IMPL=py

ROOT=/lustre/orion/med106/world-shared/sfw
# SWIFT=$ROOT/swift-t/2023-05-08  # MPI-IO fix
# SWIFT=$ROOT/swift-t/2023-05-10  # PMI SYNC
SWIFT=$ROOT/swift-t/2023-06-22    # srun usage update

export TURBINE_HOME=$SWIFT/turbine
PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH

PY=/lustre/orion/world-shared/med106/gounley1/conda543
PATH=$PY/bin:$PATH

# EMEWS Queues for R
# EQR=$ROOT/EQ-R

# EQPy=$WORKFLOWS_ROOT/common/ext/EQ-Py

# For test output processing:
LOCAL=0
CRAY=1
