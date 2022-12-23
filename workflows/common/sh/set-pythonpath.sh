
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

BENCHMARKS_DEFAULT=$( cd $EMEWS_PROJECT_ROOT/../../../Benchmarks ; /bin/pwd )
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

export APP_PYTHONPATH=${APP_PYTHONPATH:-empty}

PYTHONPATH+=:$WORKFLOWS_ROOT/common/python

# Add known CANDLE Benchmarks to PYTHONPATH
PYTHONPATH+=:$BENCHMARKS_ROOT/Pilot1/P1B1
PYTHONPATH+=:$BENCHMARKS_ROOT/Pilot1/Attn1
PYTHONPATH+=:$BENCHMARKS_ROOT/Pilot1/NT3
PYTHONPATH+=:$BENCHMARKS_ROOT/examples/ADRP
PYTHONPATH+=:$BENCHMARKS_ROOT/examples/xform-smiles

if [[ ${MODEL_PYTHON_DIR:-} != "" ]]
then
  PYTHONPATH+=:$MODEL_PYTHON_DIR
fi
