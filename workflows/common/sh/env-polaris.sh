
# ENV Polaris

# CANDLE_MODEL_IMPL=echo
CANDLE_MODEL_IMPL=app

# CSC249=/lus/grand/projects/CSC249ADOA01
# ROOT=$CSC249/public/sfw/polaris
# # SWIFT=$ROOT/swift-t/2023-06-05
# SWIFT=$ROOT/swift-t/2023-08-31

CANDLE_ECP=/eagle/Candle_ECP
ROOT=$CANDLE_ECP/sfw
SWIFT=$ROOT/swift-t/2024-03-13

if ! [[ -d $SWIFT ]]
then
  echo "Not found: SWIFT=$SWIFT"
  exit 1
fi

export TURBINE_HOME=$SWIFT/turbine
PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH

PY=$CANDLE_ECP/conda/2024-03-12

PATH=$PY/bin:$PATH

# R_HOME=$ROOT/R-4.2.2/lib64/R
# EQR=$ROOT/EQ-R

module load PrgEnv-nvhpc

# export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$R_HOME/lib
