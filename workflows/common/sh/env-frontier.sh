
# ENV Crusher

module load PrgEnv-gnu
module load gcc/11.2.0
module load rocm/5.4.0
export LD_PRELOAD="/usr/lib64/libcrypto.so /usr/lib64/libssh.so.4 /usr/lib64/libssl.so.1.1"

# SWIFT_IMPL=echo
SWIFT_IMPL=py

# SWIFT=$ROOT/swift-t/2022-07-25  # Works
# SWIFT=$ROOT/swift-t/2023-02-23
SWIFT=/lustre/orion/world-shared/med106/gounley1/swift-t-install

export TURBINE_HOME=$SWIFT/turbine
PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH

# Set up Python:
# PY=/lustre/orion/world-shared/med106/gounley1/conda230623
PY=/mnt/bb/gounley1/conda230623
export PYTHONHOME=$PY
PATH=$PY/bin:$PATH

# For test output processing:
LOCAL=0
CRAY=1

# Dummy setting: EQ/R is not installed on Spock yet
EQR=not-installed
