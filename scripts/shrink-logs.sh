#!/bin/bash
set -eu

# SHRINK LOGS SH
# Accepts a whole workflow output directory
# Clean up and shrink TensorFlow output logs
# See shrink-log.py for details
# Parallelizable via make

THIS=$( readlink --canonicalize $( dirname $0 ) )
CPLO=$( readlink --canonicalize $THIS/.. )
SUPERVISOR=$( readlink --canonicalize $CPLO/../.. )
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
mkdir -pv /tmp/$USER/shrink

cd $DIR
nice -n 19 make -j 8 -f $THIS/shrink-log.mk
