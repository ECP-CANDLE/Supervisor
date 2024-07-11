#!/bin/bash
set -eu

# PREPROCESS SH
# Generic preprocess wrapper for containers

THIS=$(       realpath $( dirname $0 ) )
SUPERVISOR=$( realpath $THIS/.. )
export THIS

source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "See README.adoc" \
          SIF MODEL DATA_SOURCE OUTDIR - ${*}

# OUTDIR must be under /candle_data_dir

if [[ ${CANDLE_DATA_DIR:-} == "" ]]
then
  abort "Set CANDLE_DATA_DIR!"
fi

A=( --bind $CANDLE_DATA_DIR:/candle_data_dir
    $SIF preprocess.sh /candle_data_dir
    --train_split_file ${DATA_SOURCE}_split_0_train.txt
    --val_split_file   ${DATA_SOURCE}_split_0_val.txt
    --test_split_file  ${DATA_SOURCE}_split_0_test.txt
    --ml_data_outdir   $OUTDIR
  )

renice --priority 19 $$

set -x
/usr/bin/time -f "TIME: %e" singularity exec --nv ${A[@]}
