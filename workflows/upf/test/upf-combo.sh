#!/bin/sh
set -eu

# TEST UPF 1

if (( ${#} != 2 ))
then
  echo "usage: test SITE UPF"
  exit 1
fi

SITE=$1
UPF=$2

# Self-configure
THIS=$(               cd $( dirname $0 ) ; /bin/pwd )
EMEWS_PROJECT_ROOT=$( cd $THIS/..        ; /bin/pwd )
WORKFLOWS_ROOT=$(     cd $THIS/../..     ; /bin/pwd )
export EMEWS_PROJECT_ROOT

export MODEL_NAME="combo" OBJ_RETURN="val_loss"
CFG_SYS=$THIS/cfg-sys-1.sh

$EMEWS_PROJECT_ROOT/swift/workflow.sh $SITE -a $CFG_SYS $THIS/$UPF
