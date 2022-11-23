#!/bin/bash
set -eu

# SHRINK LOGS SH
# Accepts a whole workflow output directory
# Clean up and shrink TensorFlow output logs
# See shrink-log.py for details
# Parallelizable via make

THIS=$(       realpath $( dirname $0 ) )
SUPERVISOR=$( realpath $THIS/.. )
export THIS

source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an output DIR (e.g., .../experiments/X042/out)!" \
          DIR - ${*}

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

if ! [[ -d $DIR ]]
then
  echo "Does not exist: $DIR"
  exit 1
fi

# This is used inside the Makefile below:
export TMP_SHRINK=/tmp/$USER/shrink
mkdir -pv $TMP_SHRINK

cd $DIR
nice -n 19 make -j 4 -f $THIS/shrink-log.mk
