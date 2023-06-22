
# ENV Polaris

# CANDLE_MODEL_IMPL=echo
CANDLE_MODEL_IMPL=app

CSC249=/lus/grand/projects/CSC249ADOA01
ROOT=$CSC249/public/sfw/polaris
SWIFT=$ROOT/swift-t/2023-06-05

if ! [[ -d $SWIFT ]]
then
  echo "Not found: SWIFT=$SWIFT"
  exit 1
fi

export TURBINE_HOME=$SWIFT/turbine
PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH

PY=$ROOT/Miniconda-2023-06-16

PATH=$PY/bin:$PATH

R_HOME=$ROOT/R-4.2.2/lib64/R
EQR=$ROOT/EQ-R

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:$R_HOME/lib
