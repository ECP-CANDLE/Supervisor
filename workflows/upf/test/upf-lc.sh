#!/bin/sh
set -eu

# TEST UPF 1

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

export MODEL_NAME="nn_reg0" OBJ_RETURN="val_loss"
CFG_SYS=$THIS/cfg-sys-lc.sh

$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a $CFG_SYS $THIS/upf-lc.txt
