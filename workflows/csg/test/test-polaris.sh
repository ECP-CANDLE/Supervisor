#!/bin/bash
set -eu

# CMP-CV TEST SMALL 1

if (( ${#} != 1 ))
then
  echo "usage: test SITE"
  exit 1
fi

# export MODEL_NAME=$1
SITE=$1

# Self-configure
THIS=$(               cd $( dirname $0 ) ; /bin/pwd )
EMEWS_PROJECT_ROOT=$( cd $THIS/..        ; /bin/pwd )
WORKFLOWS_ROOT=$(     cd $THIS/../..     ; /bin/pwd )
export EMEWS_PROJECT_ROOT

export OBJ_RETURN="val_loss"
CFG_SYS=$THIS/cfg-sys-1.sh

# export MODEL_NAME="DrugCell"
# export CANDLE_IMAGE=/homes/ac.gpanapitiya/ccmg-mtg/Singularity/DrugCell.sif
export CANDLE_MODEL_TYPE="SINGULARITY"

# model-1.txt is not used currently
$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a $CFG_SYS $THIS/upf-graphdrp-polaris.txt $THIS/models-1.txt
