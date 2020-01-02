#!/bin/sh

# TIME DATAFRAME SH

# Report the average time to create the dataframe

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide an experiment DIR (e.g., .../experiments/X042)!" \
          DIR - ${*}

if [[ ! -d $DIR ]]
then
  echo "$0: Given experiment directory does not exist: $DIR"
  exit 1
fi

grep -o "dataframe.*seconds" $DIR/out/out-*.txt | awk -f $THIS/time-dataframe.awk
