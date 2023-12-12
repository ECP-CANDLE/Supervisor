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
SUPERVISOR_HOME=$(    cd $THIS/../../..  ; /bin/pwd )
export EMEWS_PROJECT_ROOT

export MODEL_RETURN="val_loss"

# export MODEL_NAME="DrugCell"
# export CANDLE_IMAGE=/homes/ac.gpanapitiya/ccmg-mtg/Singularity/DrugCell.sif
export CANDLE_MODEL_TYPE="SINGULARITY"

source $SUPERVISOR_HOME/workflows/common/sh/utils.sh
sv_path_append $SUPERVISOR_HOME/workflows/common/sh

export CFG_SYS=$THIS/cfg-sys-1.sh
export UPF=$THIS/upf-1.txt
export MODEL_NAME="CMP-CV"


$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a $CFG_SYS $UPF $THIS/models-1.txt
