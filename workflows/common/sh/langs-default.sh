
# LANGS DEFAULT

# Assumes everything is in your paths, except the project Python code

export PYTHONPATH=${EMEWS_PROJECT_ROOT}/python:${PYTHONPATH:-}

SWIFT_IMPL=app

# Resident task workers and ranks
export TURBINE_RESIDENT_WORK_WORKERS=1
export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
