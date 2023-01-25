#!/bin/bash
set -eu

# TEST MLRMBO GDRP 1
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

# Select configurations
export CFG_SYS=$THIS/cfg-sys-nightly.sh
export CFG_PRM=$THIS/cfg-prm-nightly.sh

# Specify the mlrMBO algorithm R file
export R_FILE=mlrMBO-mbo.R

CANDLE_MODEL_TYPE="SINGULARITY"
# CANDLE_IMAGE=/software/improve/images/GraphDRP.sif # lambda
CANDLE_IMAGE=/lus/grand/projects/CSC249ADOA01/images/GraphDRP.sif # Polaris


export MODEL_NAME="graphdrp"

# Currently ignored:
export OBJ_RETURN="val_loss"

$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a $CFG_SYS $CFG_PRM $MODEL_NAME \
                                      $CANDLE_MODEL_TYPE $CANDLE_IMAGE
