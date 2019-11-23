#!/bin/bash -l
set -eu

# SUBMIT SH

THIS=$( readlink --canonicalize $( dirname $0 ) )

DIRECTORY=$THIS
OUTPUT=$THIS/output.txt

source $THIS/settings.sh

if [[ -f $OUTPUT ]]
then
  mv --backup=numbered $OUTPUT $OUTPUT.bak
fi

set -x
qsub -n $WORKERS \
     -t $WALLTIME \
     -A $PROJECT \
     -q $QUEUE \
     -o $OUTPUT \
     -e $OUTPUT \
     --env THIS=$THIS \
     --cwd $DIRECTORY \
     --jobname $JOBNAME \
     $THIS/job.sh
