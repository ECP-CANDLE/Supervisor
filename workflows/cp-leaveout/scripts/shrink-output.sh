#!/bin/bash

# SHRINK OUTPUT SH
# Accepts a whole workflow output directory
# Clean up and shrink TensorFlow output
# See shrink-output.py for details

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

OUTS=()

mkdir -pv /tmp/$USER

cd $D/out
nice -n 19 make -j 8 -f $THIS/shrink-output.mk
