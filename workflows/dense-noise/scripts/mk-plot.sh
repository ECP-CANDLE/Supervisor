#!/bin/bash
set -eu

# MAKE PLOT SH

THIS=$( realpath $( dirname $0 ) )
D_N=$(  realpath $THIS/.. )
SUPERVISOR=$( realpath $D_N/../.. )

source $SUPERVISOR/workflows/common/sh/utils.sh

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

if ! [[ -d $DIR ]]
then
  echo "Directory does not exist: $DIR"
  exit 1
fi

python $THIS/mk-plot.py $DIR/plot.h5 $DIR/heat.png
