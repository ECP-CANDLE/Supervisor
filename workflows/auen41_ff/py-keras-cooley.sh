#!/bin/sh
set -eu

if [[ ${#} != 1 ]]
then
  echo "Requires data directory!"
  exit 1
fi

DATA_DIRECTORY=$1

THIS=$( cd $( dirname $0 ) ; /bin/pwd )

# PYTHONPATH
PP=
PP+=/soft/analytics/conda/env/Candle_ML/lib/python2.7/site-packages:
PP+=/soft/analytics/conda/env/Candle_ML/lib/python2.7:
PP+=$THIS
# PYTHONHOME
PH=/soft/analytics/conda/env/Candle_ML

ENVS="-e PYTHONHOME=$PH -e PYTHONPATH=$PP"
swift-t -m cobalt -s $THIS/settings.sh $ENVS \
        $THIS/py-keras.swift --data-directory=$DATA_DIRECTORY
