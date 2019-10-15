#! /usr/bin/env bash
set -eu

# TEST UPF 
if [ "$#" -ne 2 ]; then
  echo "usage: upf-test-model SITE UPF_TEXT"
  exit 1
fi

SITE=$1

# Self-configure
THIS=$(               cd $( dirname $0 ) ; /bin/pwd )
EMEWS_PROJECT_ROOT=$( cd $THIS/..        ; /bin/pwd )
WORKFLOWS_ROOT=$(     cd $THIS/../..     ; /bin/pwd )
export EMEWS_PROJECT_ROOT

#export SWIFT_T=/home/nick/sfw/swift-t-171
#export PYTHONHOME=/home/nick/anaconda3
#export PYTHON=/home/nick/anaconda3/bin/python

export MODEL_NAME="model" OBJ_RETURN="val_loss"
CFG_SYS=$THIS/cfg-sys-upf.sh

# Source some utility functions used by EMEWS in this script
source $WORKFLOWS_ROOT/common/sh/utils.sh
# auto create expid
EXP="-a"
# create turbine output based on expid
get_expid $EXP

$EMEWS_PROJECT_ROOT/swift/upf.sh $SITE -a $CFG_SYS $2

echo $EXPID
echo $TURBINE_OUTPUT
