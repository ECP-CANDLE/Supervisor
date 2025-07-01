
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
puts "TURBINE WORKER HOOK: offset $env(ADLB_RANK_OFFSET)"
set env(ZE_AFFINITY_MASK) [ expr $env(ADLB_RANK_OFFSET) ]
puts ZE_AFFINITY_MASK=$env(ZE_AFFINITY_MASK)
flush stdout
set env(ITEX_LIMIT_MEMORY_SIZE_IN_MB) 8192
'

# set env(ITEX_LIMIT_MEMORY_SIZE_IN_MB) 8192
# set env(ITEX_ENABLE_NEXTPLUGGABLE_DEVICE) 0
# set env(TF_ENABLE_LAYOUT_OPT) 0
# set env(TF_NUM_INTEROP_THREADS) 1

# These produced ~ 1% savings:
# set env(ITEX_AUTO_MIXED_PRECISION) 1
# set env(ITEX_AUTO_MIXED_PRECISION_DATA_TYPE) BFLOAT16


export PROCS=${PROCS:-4}
export PPN=${PPN:-1}

export TURBINE_HOME=$SWIFT/turbine
PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH
# PATH=$PY/bin:$PATH

module load oneapi
