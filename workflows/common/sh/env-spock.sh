
# ENV Spock

# SWIFT_IMPL=echo
SWIFT_IMPL=py

# CANDLE software installation root:
MED106=/gpfs/alpine/world-shared/med106
# ROOT=$MED106/sw/spock/gcc-10.3.0
ROOT=$MED106/sw/spock/gcc-11.2.0

# Add Swift/T to PATH
SWIFT=$ROOT/swift-t/2021-11-14
PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH

# Set up Python:
PY=/gpfs/alpine/med106/world-shared/hsyoo/spock_tf2_py37_rocm42
export PYTHONHOME=$PY

# For test output processing:
LOCAL=0
CRAY=1

# Dummy setting: EQ/R is not installed on Spock yet
EQR=not-installed
