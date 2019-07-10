#!/bin/bash
set -eu

# MODEL.SH

# Shell wrapper around uno_infer

usage()
{
  echo "Usage: infer.sh INSTANCE_DIRECTORY DATA_FILE MODEL_FILE NUM_PREDICTIONS RUN_ID"
}

if (( ${#} != 5 ))
then
  usage
  exit 1
fi

INSTANCE_DIRECTORY=$1 
DF="$2"
MODEL_FILE="$3"
N_PRED=$4
RUN_ID=$5


DATA_FILE=$DF

# Uncomment these three lines and edit the DATA_FILE
# if you want to make multiple copies of the
# data input file to avoid io contention.
# FNAME=$( basename $DF )
# DATA_FILE=/mnt/bb/$USER/${RUN_ID}_${FNAME}
# cp -u $DF $DATA_FILE

# All stdout/stderr after this point goes into model.log !
mkdir -p $INSTANCE_DIRECTORY
LOG_FILE=$INSTANCE_DIRECTORY/infer.log
exec >> $LOG_FILE
exec 2>&1
cd $INSTANCE_DIRECTORY

echo "INFER.SH START:"
echo "DATA_FILE: $DATA_FILE"
echo "MODEL_FILE: $MODEL_FILE"

# Source langs-app-{SITE} from workflow/common/sh/ (cf. utils.sh)
WORKFLOWS_ROOT=$( cd $EMEWS_PROJECT_ROOT/.. ; /bin/pwd )
source $WORKFLOWS_ROOT/common/sh/utils.sh
source_site langs-app $SITE

echo
echo "USING PYTHON:"
which python

DATA="--data=$DATA_FILE"
MODEL="--model=$MODEL_FILE"
N_PRED="--n_pred=$N_PRED"

# python uno_infer.py --data CTRP_CCLE_2000_1000_test.h5 --model_file model.h5 --weights_file weights.h5 --n_pred
arg_array=( "$BENCHMARKS_ROOT/Pilot1/Uno/uno_infer.py" "$DATA" "$MODEL" "$N_PRED" )
MODEL_CMD="python -u ${arg_array[@]}"

echo MODEL_CMD: $MODEL_CMD

python -u "${arg_array[@]}"

echo "MODEL.SH END: SUCCESS"
exit 0 # Success

# Local Variables:
# sh-basic-offset: 2
# End:
