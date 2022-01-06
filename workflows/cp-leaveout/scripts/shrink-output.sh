#!/bin/bash
set -eu

# SHRINK OUTPUT SH
# Accepts a whole workflow output directory
# Clean up and shrink TensorFlow output
# See shrink-output.py for details
# Parallelizable via make

THIS=$( readlink --canonicalize $( dirname $0 ) )
CPLO=$( readlink --canonicalize $THIS/.. )
SUPERVISOR=$( readlink --canonicalize $CPLO/../.. )
export THIS

source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

if ! [[ -d $DIR ]]
then
  echo "Does not exist: $DIR"
  exit 1
fi

# This is used inside the Makefile below:
mkdir -pv /tmp/$USER/shrink

cd $DIR/out
nice -n 19 make -j 1 -f $THIS/shrink-output.mk
