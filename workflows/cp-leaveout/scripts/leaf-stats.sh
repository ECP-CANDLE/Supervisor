#!/bin/bash
set -eu

# LEAF STATS
# Report stats for given nodes
# LIST: A file containing a simple per-line list of nodes,
#    e.g., "1.1.2\n2.3.1\n4.1.1.1\n"

THIS=$( realpath $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an run DIR (e.g., .../experiments/X042/run/1.2.3)!" \
          -H "Provide a node list (from list-node-singles)" \
          DIR LIST - ${*}

if [[ ! -d $DIR ]]
then
  echo "$0: Given run directory does not exist: $DIR"
  exit 1
fi

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

python $THIS/leaf-stats.py $DIR $LIST
