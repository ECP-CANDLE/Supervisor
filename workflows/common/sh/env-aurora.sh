
# ENV Aurora

# CANDLE_MODEL_IMPL=echo
# CANDLE_MODEL_IMPL=app
CANDLE_MODEL_IMPL=py
# CANDLE_MODEL_IMPL=container

SFW=/lus/flare/projects/candle_aesp_CNDA/sfw
# SWIFT=$SFW/aurora/swift-t/2025-06-12-hed
SWIFT=$SFW/aurora/swift-t/2025-06-03-tmp
# PY=$SFW/TF-2025-05-23
PY=/tmp/TF

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
PATH=$PY/bin:$PATH

module load oneapi
