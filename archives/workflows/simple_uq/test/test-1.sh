#!/bin/sh
set -eu

# UQ TEST 1

if [ ${#} != 1 ]
then
  echo "Requires SITE!"
  exit 1
fi

SITE=$1

THIS=$( dirname $0 )
PROJECT_ROOT=$( cd $THIS/.. ; /bin/pwd )

$PROJECT_ROOT/swift/workflow.sh $SITE -a $THIS/cfg-sys-1.sh $THIS/cfg-prm-1.sh
