
# ENV Spock

# SWIFT_IMPL=echo
SWIFT_IMPL=py

# CANDLE software installation root:
MED106=/gpfs/alpine/world-shared/med106
ROOT=$MED106/gounley1/crusher2

# Add Swift/T to PATH
SWIFT=$ROOT/swift-t-install
PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH

# Set up Python:
PY=/gpfs/alpine/med106/world-shared/gounley1/crusher2/conda520tf
export PYTHONHOME=$PY

# For test output processing:
LOCAL=0
CRAY=1

# Dummy setting: EQ/R is not installed on Spock yet
EQR=not-installed
