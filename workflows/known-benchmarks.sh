
# Known Benchmarks
# Generate the list of Benchmarks that Supervisor knows about
# To add a Known Benchmark, add its paths to BENCHMARKS_DIRS_BASE below
# To call an unknown model,
#         set environment variable MODEL_NAME to the short name
#         set PYTHONPATH and/or APP_PYTHONPATH as needed

BENCHMARKS_DEFAULT=$( cd $EMEWS_PROJECT_ROOT/../../../Benchmarks ; /bin/pwd )
export BENCHMARKS_ROOT=${BENCHMARKS_ROOT:-${BENCHMARKS_DEFAULT}}

BENCHMARKS_DIRS_BASE=""
BENCHMARKS_DIRS_BASE+=$BENCHMARKS_ROOT/Pilot1/P1B1:
BENCHMARKS_DIRS_BASE+=$BENCHMARKS_ROOT/Pilot1/Attn1:
BENCHMARKS_DIRS_BASE+=$BENCHMARKS_ROOT/Pilot1/NT3:
BENCHMARKS_DIRS_BASE+=$BENCHMARKS_ROOT/examples/ADRP:
BENCHMARKS_DIRS_BASE+=$BENCHMARKS_ROOT/examples/xform-smiles

export BENCHMARK_TIMEOUT
export BENCHMARK_DIRS=${BENCHMARK_DIR:-$BENCHMARKS_DIR_BASE}

# Set PYTHONPATH and/or APP_PYTHONPATH appropriately based on SWIFT_IMPL
# ...

APP_PYTHONPATH+=:$BENCHMARK_DIRS:$BENCHMARKS_ROOT/common
    PYTHONPATH+=:$BENCHMARK_DIRS:$BENCHMARKS_ROOT/common

export APP_PYTHONPATH
