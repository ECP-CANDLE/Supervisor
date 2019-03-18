
# ENV Pascal
# Environment settings for Pascal (Swift, Python, R, Tcl, etc.)

if [ -z "$SUPERVISOR_HOME" ]; then echo "SUPERVISOR_HOME is blank"; else echo "SUPERVISOR_HOME is set to '$SUPERVISOR_HOME'"; fi
source ${SUPERVISOR_HOME}/spack/loads

SWIFT_IMPL=app

# EMEWS Queues for R
EQR=$(spack location -i eqr)

# For test output processing:
LOCAL=0

# Resident task workers and ranks
if [ -z ${TURBINE_RESIDENT_WORK_WORKERS+x} ]
then
    # Resident task workers and ranks
    export TURBINE_RESIDENT_WORK_WORKERS=1
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi
