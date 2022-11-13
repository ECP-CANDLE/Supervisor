
# ENV GCE
# Environment settings for ANL/GCE compute nodes

SFW=/nfs/gce/projects/Swift-T/sfw/x86_64
SWIFT=$SFW/swift-t/mpich/2022-11-09-Jenkins

PATH=$SWIFT/stc/bin:$PATH

EQR=not-installed

# For test output processing:
export LOCAL=1
export CRAY=0

LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}
SWIFT_IMPL="app"

# Cf. utils.sh
log_path LD_LIBRARY_PATH
log_path PYTHONPATH
