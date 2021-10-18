#!/bin/bash

# SHRINK OUTPUT SH
# Accepts a whole workflow output directory
# Clean up and shrink TensorFlow output
# See shrink-output.py for details

THIS=$( readlink --canonicalize $( dirname $0 ) )
CPLO=$( readlink --canonicalize $THIS/.. )
SUPERVISOR=$( readlink --canonicalize $CPLO/../.. )

source $SUPERVISOR/workflows/common/sh/utils.sh

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

if ! [[ -d $DIR ]]
then
  echo "Does not exist: $DIR"
  exit 1
fi

OUTS=()

find $DIR/out -name "out-*" | python $THIS/shrink-output.py
