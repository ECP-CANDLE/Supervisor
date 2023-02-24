
# ENV Crusher

# SWIFT_IMPL=echo
SWIFT_IMPL=py

ROOT=/autofs/nccs-svm1_home1/wozniak/Public/sfw/frontier
# SWIFT=$ROOT/swift-t/2022-07-25  # Works
SWIFT=$ROOT/swift-t/2023-02-23

export TURBINE_HOME=$SWIFT/turbine
PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH

# Set up Python:
# PY=/gpfs/alpine/med106/proj-shared/hm0/candle_tf_2.10
PY=/gpfs/alpine/world-shared/med106/gounley1/frontier/conda540b
export PYTHONHOME=$PY
PATH=$PY/bin:$PATH

# For test output processing:
LOCAL=0
CRAY=1

# Dummy setting: EQ/R is not installed on Spock yet
EQR=not-installed
