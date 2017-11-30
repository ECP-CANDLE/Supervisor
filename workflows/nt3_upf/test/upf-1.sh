#!/bin/sh
set -eu

if (( ${#} != 1 ))
then
  echo "usage: test SITE"
  exit 1
fi

SITE=$1

# Self-configure
THIS=$( dirname $0 )
EMEWS_PROJECT_ROOT=$( cd $THIS/..    ; /bin/pwd )
WORKFLOWS_ROOT=$(     cd $THIS/../.. ; /bin/pwd )
export EMEWS_PROJECT_ROOT

CFG_SYS=$THIS/cfg-sys-1.sh

$PROJECT_ROOT/swift/workflow.sh $SITE -a $CFG_SYS
