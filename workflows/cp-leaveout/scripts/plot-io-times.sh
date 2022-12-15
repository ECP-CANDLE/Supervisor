#!/bin/bash
set -eu

# PLOT IO TIMES SH

# Input:  Provide an experiment directory DIR
# Output: Plots in PWD for data

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

# SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
#           DIR - ${*}

# if [[ ! -d $DIR ]]
# then
#   echo "$0: Given experiment directory does not exist: $DIR"
#   exit 1
# fi

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

DIRS=( ${*} )
BUILDS=""
LOADS=""
WRITES=""
for DIR in ${DIRS[@]}
do
  # python $THIS/plot_io_times.py $DIR

  X=$( basename $DIR )
  D=builds-$X.data
  cp -uv $DIR/builds.data $D
  BUILDS+="$D "

  X=$( basename $DIR )
  D=loads-$X.data
  cp -uv $DIR/loads.data $D
  LOADS+="$D "

  X=$( basename $DIR )
  D=writes-$X.data
  cp -uv $DIR/writes.data $D
  WRITES+="$D "

done

set -x
jwplot builds.eps $THIS/stage-builds.cfg $BUILDS
jwplot writes.eps $THIS/stage-writes.cfg $WRITES
jwplot loads.eps $THIS/stage-loads.cfg $LOADS
