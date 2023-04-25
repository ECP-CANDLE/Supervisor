
# ENV Crusher

# CANDLE_MODEL_IMPL=echo
CANDLE_MODEL_IMPL=py

# CANDLE software installation root:
MED106=/gpfs/alpine/world-shared/med106

# Gounley installation:
ROOT=$MED106/gounley1/crusher2
SWIFT=$ROOT/swift-t-install

# Wozniak installation:
# ROOT=$MED106/sw/crusher/gcc-11.2.0
# SWIFT=$ROOT/swift-t/2022-08-10

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
