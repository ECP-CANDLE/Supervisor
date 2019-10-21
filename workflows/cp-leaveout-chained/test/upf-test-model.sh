#! /usr/bin/env bash
set -eu

module unload python
# module list

# TEST UPF 
if [ "$#" -ne 4 ]; then
  echo "usage: upf-test-model SITE CFG_SYS UPF_FILE PLAN_GEN_FILE TURBINE_DIRECTIVE"
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

CFG_SYS=$THIS/$2
UPF_FILE=$3

# For #BSUB

export TURBINE_DIRECTIVE=$4

$EMEWS_PROJECT_ROOT/swift/upf.sh $SITE -a $CFG_SYS $UPF_FILE
