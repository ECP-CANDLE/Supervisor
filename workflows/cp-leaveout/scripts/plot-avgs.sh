#!/bin/bash
set -eu

# PLOT AVGS SH

# Input:  Provide an experiment directory DIR
# Output: Plots in PWD for data from times.data & vloss.data

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

DIRS=( ${*} )
TIMES=""
VLOSS=""
for DIR in ${DIRS[@]}
do
  X=$( basename $DIR )

  D=times-$X.data
  cp -uv $DIR/times.data $D
  TIMES+="$D "

  # D=vloss-$X.data
  # cp $DIR/vloss.data $D
  # VLOSS+="$D "
done

jwplot stage-times.eps $THIS/stage-times.cfg $TIMES
# jwplot stage-vloss.eps $THIS/stage-vloss.cfg $VLOSS
