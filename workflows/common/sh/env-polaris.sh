
# ENV Polaris

# CANDLE_MODEL_IMPL=echo
# CANDLE_MODEL_IMPL=app
# CANDLE_MODEL_IMPL=py
CANDLE_MODEL_IMPL=container

CANDLE_ECP=/eagle/Candle_ECP
ROOT=$CANDLE_ECP/sfw
SWIFT=$ROOT/swift-t/2024-05-23

if ! [[ -d $SWIFT ]]
then
  echo "Not found: SWIFT=$SWIFT"
  exit 1
fi

# Set CUDA_VISIBLE_DEVICES for CANDLE_MODEL_IMPL=py cases
# using Turbine hook:
export TURBINE_WORKER_HOOK_STARTUP='
puts "TURBINE WORKER HOOK"
set env(CUDA_VISIBLE_DEVICES) $env(ADLB_RANK_OFFSET)
puts CUDA_VISIBLE_DEVICES=$env(CUDA_VISIBLE_DEVICES)
'

export TURBINE_HOME=$SWIFT/turbine
PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH

module use /soft/modulefiles
module load conda
conda activate

# PATH=$PY/bin:$PATH

module load PrgEnv-gnu
