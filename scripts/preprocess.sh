#!/bin/bash
set -eu

# PREPROCESS SH
# Generic preprocess wrapper for containers

THIS=$(       realpath $( dirname $0 ) )
SUPERVISOR=$( realpath $THIS/.. )
export THIS

source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "See README.adoc" \
          IMG DATA_SOURCE - ${*}

if [[ ${CANDLE_DATA_DIR:-} == "" ]]
then
  abort "Set CANDLE_DATA_DIR!"
fi

IMAGE=/software/improve/images/$IMG.sif
RAW_DATA_DIR=$CANDLE_DATA_DIR

A=( --bind ${RAW_DATA_DIR}:/candle_data_dir
    ${IMAGE} preprocess.sh /candle_data_dir \
             --train_split_file ${DATA_SOURCE}_split_0_train.txt \
             --val_split_file ${DATA_SOURCE}_split_0_val.txt \
             --test_split_file ${DATA_SOURCE}_split_0_test.txt \
             --ml_data_outdir /candle_data_dir/HPO/$IMG/$DATA_SOURCE
  )

renice --priority 19 $$

set -x
/usr/bin/time -f "TIME: %e" singularity exec --nv ${A[@]}
