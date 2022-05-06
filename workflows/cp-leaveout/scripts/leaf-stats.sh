#!/bin/bash
set -eu

# LEAF STATS
# Report stats for given nodes
# LIST: A file containing a simple per-line list of nodes,
#    e.g., "1.1.2\n2.3.1\n4.1.1.1\n"

THIS=$( readlink --canonicalize $( dirname $0 ) )

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

# Read the node list into a Bash array
NODES=()
while read NODE CELL
do
  NODES+=( $NODE )
  CELLS+=( $CELL )
done < $LIST

{
  echo "CELL NODE POINTS EPOCHS MAE R2 VAL_LOSS EARLY"
  for (( i=1 ; i < ${#NODES[@]} ; i++ ))
  do
    NODE=${NODES[$i]}
    CELL=${CELLS[$i]}
    LOG=$D/run/$NODE/save/python.log
    # Pull out validation points:
    POINTS=$( grep "Data points per epoch:" < $LOG | cut -d ' ' -f 12 )
    echo -n "$CELL $NODE ${POINTS:0:-1} "
    # grep "loss:" $LOG | tail -1
    # Grab the last Epoch line in the log,
    #      extract the desired stats,
    #      remove commas, delete trailing newline
    grep "loss:" $LOG | tail -1 | \
      awk '{ printf( "%i %f %+f %f ", strtonum($4), strtonum($8), strtonum($10), strtonum($12)); }' | \
      tr ',' ' ' | tr --delete '\n'
    if grep -q "stopping: early" $LOG
    then
      EARLY=1
    else
      EARLY=0
    fi
    echo $EARLY
  done
} | column -t
