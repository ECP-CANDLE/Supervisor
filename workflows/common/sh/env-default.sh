
# LANGS DEFAULT

# Assumes everything is in your paths, except the project Python code

export PYTHONPATH=${EMEWS_PROJECT_ROOT}/python:${PYTHONPATH:-}

SWIFT_IMPL=app

# Resident task workers and ranks
if [ -z ${TURBINE_RESIDENT_WORK_WORKERS+x} ]
then
    # Resident task workers and ranks
    export TURBINE_RESIDENT_WORK_WORKERS=1
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi

# This can be used for an OpenMPI hosts file
# export TURBINE_LAUNCH_OPTIONS="--hostfile $HOME/hosts.txt"
