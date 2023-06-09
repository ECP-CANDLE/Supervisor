#!/bin/bash
set -eu

# TEST UPF GDRP 1
# For GraphDRP

if (( ${#} != 1 ))
then
  echo "usage: test SITE"
  exit 1
fi

SITE=$1

# Self-configure
THIS=$(               cd $( dirname $0 ) ; /bin/pwd )
EMEWS_PROJECT_ROOT=$( cd $THIS/..        ; /bin/pwd )
WORKFLOWS_ROOT=$(     cd $THIS/../..     ; /bin/pwd )
export EMEWS_PROJECT_ROOT

export OBJ_RETURN="val_loss"
CFG_SYS=$THIS/cfg-sys-1.sh

export CANDLE_IMAGE=/lus/grand/projects/CSC249ADOA01/images/GraphDRP.sif
export CANDLE_MODEL_TYPE="SINGULARITY"
export MODEL_NAME="GraphDRP"

$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a $CFG_SYS $THIS/upf-1.txt
