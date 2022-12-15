
# ENV GCE
# Environment settings for ANL/GCE compute nodes

SFW=/nfs/gce/projects/Swift-T/sfw/x86_64/U20
# Python only:
# SWIFT=$SFW/swift-t/mpich/2022-11-14-Jenkins
# Python+R:
SWIFT=$SFW/swift-t/mpich/2022-11-14-Jenkins

PATH=$SWIFT/stc/bin:$PATH

echo $SWIFT

# Needed for Swift/T+R
export LD_LIBRARY_PATH=$SFW/R-4.1.0/lib/R/lib

export PYTHONPATH=${PYTHONPATH:-}

EQR=$SFW/EQ-R
SWIFT_IMPL="app"

# For test output processing:
export LOCAL=1
export CRAY=0

# Cf. utils.sh
log_path PATH
log_path LD_LIBRARY_PATH
log_path PYTHONPATH
