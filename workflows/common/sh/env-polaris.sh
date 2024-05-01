
# ENV Polaris

# Polaris has a fork() bug- must use python(): 2024-04-02
# https://docs.alcf.anl.gov/polaris/known-issues
# CANDLE_MODEL_IMPL=echo
# CANDLE_MODEL_IMPL=app
CANDLE_MODEL_IMPL=py

CANDLE_ECP=/eagle/Candle_ECP
ROOT=$CANDLE_ECP/sfw
SWIFT=$ROOT/swift-t/2024-04-29

if ! [[ -d $SWIFT ]]
then
  echo "Not found: SWIFT=$SWIFT"
  exit 1
fi

export TURBINE_HOME=$SWIFT/turbine
PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH

module use /soft/modulefiles
module load conda
conda activate

# PATH=$PY/bin:$PATH

# module load PrgEnv-nvhpc
module load PrgEnv-gnu
