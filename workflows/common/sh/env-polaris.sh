
# ENV Polaris
module load singularity

# SWIFT_IMPL=echo
SWIFT_IMPL=app

CSC249=/lus/grand/projects/CSC249ADOA01
ROOT=$CSC249/public/sfw/polaris
SWIFT=$ROOT/swift-t/2022-11-28

export TURBINE_HOME=$SWIFT/turbine
PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH

PY=$ROOT/Miniconda
PATH=$PY/bin:$PATH

EQR=not-installed
