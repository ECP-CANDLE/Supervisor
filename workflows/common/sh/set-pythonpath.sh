
# SET PYTHONPATH SH
# Sets up BENCHMARKS_ROOT variable and PYTHONPATH for workflows
# For CANDLE models, BENCHMARKS_ROOT is the CANDLE Benchmarks repo
# EMEWS_PROJECT_ROOT should be set by the calling script
# User may set BENCHMARKS_ROOT to override defaults
#       BENCHMARKS_ROOT must exist as directory,
#       although it may be empty/unused
# Repo structure is Supervisor/workflows/PROJECT ,
# with Benchmarks normally alongside Supervisor
# If MODEL_PYTHON_DIR is set, that is added to PYTHONPATH

SUPERVISOR=$( cd $EMEWS_PROJECT_ROOT/../.. ; /bin/pwd )

# Set up Supervisor
export PYTHONPATH
PYTHONPATH+=:$SUPERVISOR/workflows/common/python
PYTHONPATH+=:$SUPERVISOR/models/OneD
PYTHONPATH+=:$SUPERVISOR/models/Random
PYTHONPATH+=:$SUPERVISOR/models/Comparator
PYTHONPATH+=:$SUPERVISOR/workflows/common/ext/EQ-Py

# The remainder of this script sets up PYTHONPATHs
#     for the CANDLE Benchmarks if they are found
if ! [[ -d $SUPERVISOR/../Benchmarks ]]
then
  # The user must be running an external model or container
  return
fi
BENCHMARKS_DEFAULT=$( cd $SUPERVISOR/../Benchmarks ; /bin/pwd )
export BENCHMARKS_ROOT=${BENCHMARKS_ROOT:-${BENCHMARKS_DEFAULT}}

if [[ ! -d $BENCHMARKS_ROOT ]]
then
  echo "Could not find BENCHMARKS_ROOT: '$BENCHMARKS_ROOT'"
  return 1
fi

# This is now in candle_lib, which should be installed/available
#       in the common compute-node Python environment:  2022-12-20
# APP_PYTHONPATH+=:$BENCHMARK_DIRS:$BENCHMARKS_ROOT/common
#     PYTHONPATH+=:$BENCHMARK_DIRS:$BENCHMARKS_ROOT/common

# Add known CANDLE Benchmarks to PYTHONPATH
PYTHONPATH+=:$BENCHMARKS_ROOT/Pilot1/P1B1
PYTHONPATH+=:$BENCHMARKS_ROOT/Pilot1/Attn1
PYTHONPATH+=:$BENCHMARKS_ROOT/Pilot1/NT3
PYTHONPATH+=:$BENCHMARKS_ROOT/Pilot1/Uno
PYTHONPATH+=:$BENCHMARKS_ROOT/examples/ADRP
PYTHONPATH+=:$BENCHMARKS_ROOT/examples/xform-smiles
PYTHONPATH+=:/home/weaverr/Candle/examples/mnist

export APP_PYTHONPATH=${APP_PYTHONPATH:-$PYTHONPATH}

if [[ ${MODEL_PYTHON_DIR:-} != "" ]]
then
  PYTHONPATH+=:$MODEL_PYTHON_DIR
fi
