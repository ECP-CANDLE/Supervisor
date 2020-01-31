
# ENV SPACK
# Language settings for a Spack-based installations
# Assumes WORKFLOWS_ROOT, BENCHMARK_DIR, BENCHMARKS_ROOT are set

if [[ ${ZSH_VERSION:-} != "" ]]
then
  source /usr/share/modules/init/zsh
fi
if ! which spack > /dev/null
then
  abort "put spack in your PATH!"
fi
SPACK=$( which spack )
SPACK_ROOT=$( readlink --canonicalize $( dirname $SPACK )/.. )
export SPACK_ROOT
source $SPACK_ROOT/share/spack/setup-env.sh

spack load stc
spack load turbine
# spack load eqr

# Python
export PYTHONPATH=${PYTHONPATH:-}${PYTHONPATH:+:}
PYTHONPATH+=$WORKFLOWS_ROOT/common/python:

# Add Turbine's Python to PATH
TURBINE_PY_LIB=$( turbine -v | \
                    sed -n 's/\( using Python: \)\(.*\) \(.*\)/\2/p' )
if [[ ! -d "$TURBINE_PY_LIB" ]]
then
  abort "Turbine did not report a Python extension!"
fi
TURBINE_PY=$( readlink --canonicalize $TURBINE_PY_LIB/.. )
PATH=$TURBINE_PY/bin:$PATH

SWIFT_IMPL="app"

# # EMEWS Queues for R
# EQR=$( spack find -p eqr | sed -n 's/eqr@[.0-9]*//p' )
# EQR=$( echo $EQR ) # Trim whitespace
# export EQR
# if [[ ! -d "$EQR" ]]
# then
#   abort "could not find EQ/R!"
# fi

# R=$( spack find -p r | sed -n 's/r@[.0-9]*//p' )
# R=$( echo $R ) # Trim whitespace

# LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}${LD_LIBRARY_PATH:+:}
# LD_LIBRARY_PATH+=$R/rlib/R/lib

if [ -z ${TURBINE_RESIDENT_WORK_WORKERS+x} ]
then
    # Resident task workers and ranks
    export TURBINE_RESIDENT_WORK_WORKERS=1
    export RESIDENT_WORK_RANKS=$(( PROCS - 2 ))
fi

# For test output processing:
export LOCAL=1
export CRAY=0

# Cf. utils.sh
# log_path LD_LIBRARY_PATH
# log_path PYTHONPATH
