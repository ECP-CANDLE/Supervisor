#!/bin/bash -l
set -eu

# RUN UNO SH

echo RUN UNO START
export TZ=CDT6CST

# Text for DRYRUN case
ARGTEXT=""

# Process arguments
INPUTS=( OUTPUT ID PARALLELISM KERAS_OPTIMIZER LEARNING_RATE )
if [[ ${#} != ${#INPUTS[@]} ]]
then
  echo "run-uno.sh: requires ${INPUTS[@]}"
  echo "run-uno.sh: received $*"
  exit 1
fi
for a in ${INPUTS[@]}
do
  eval $a=$1
  ARGTEXT+=$1
  shift
done

export KMP_BLOCKTIME=0
export KMP_SETTINGS=0
export KMP_AFFINITY="granularity=fine,compact,1,0"
export OMP_NUM_THREADS=128
export NUM_INTER_THREADS=2
export NUM_INTRA_THREADS=128

UNO_HOME=$BENCHMARKS/Pilot1/Uno
VAL_LOSS_FILE=$( printf "$OUTPUT/val_loss-%04i.txt" $ID )
SUMMARY_FILE=$( printf "$OUTPUT/summary-%04i.txt" $ID )

SUMMARY_PREFIX="%-17s"
print_kv() { printf "$SUMMARY_PREFIX %s\n" ${1}: ${!1} ; }

{
  printf "$SUMMARY_PREFIX " START
  date "+%Y-%m-%d %H:%M %p"
  print_kv PARALLELISM
  print_kv KERAS_OPTIMIZER
  print_kv LEARNING_RATE
} > $SUMMARY_FILE

cd $UNO_HOME

Q=""
E=""
if (( ${DRYRUN:-0} == 1 ))
then
  Q=:
  E=echo
  # Make a number out of the arguments:
  # Hash the arguments, extract first 8 bytes
  H=$( echo $ARGTEXT | md5sum | head --bytes 8 )
  # Treat as hex value and take mod 10
  VAL_LOSS=$(( 0x$H % 10 ))
  sleep $VAL_LOSS
fi

PATH=/opt/cray/elogin/eproxy/2.0.14-4.3/bin:$PATH # For aprun
module load darshan
$Q module load alps

# module load miniconda-3.6/conda-4.4.10
CONDA=/soft/datascience/conda/miniconda3/4.4.10
PATH=$CONDA/bin:$PATH
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}${LD_LIBRARY_PATH+:}:$CONDA/lib

echo "using python:" $( which python )

# HACK: Override learning rate to known acceptable value
LEARNING_RATE=0.0000001

echo COBALT_JOBID ${COBALT_JOBID:-}

{
  echo PARALLELISM: $PARALLELISM
  printenv | sort
} > $OUTPUT/run-uno.env

set -x
set +e

$E aprun -N 1 -n $PARALLELISM \
      -cc depth -d 128 -j 4 -b \
      python $UNO_HOME/uno_baseline_keras2.py \
      --epochs 1 \
      --cache uno-landmark.cache-1 \
      -v --warmup_lr \
      --optimizer $KERAS_OPTIMIZER \
      --lr $LEARNING_RATE \
      -l $OUTPUT/uno-$ID.log \
      --use_landmark_genes

      # --save_path save \
      # --model_file uno-adam-0.0000001
#       --cp  # Checkpoint
APRUN_CODE=$?
set -e
if (( APRUN_CODE == 0 ))
then
  STATUS=SUCCESS
else
  STATUS=FAILED
fi

if (( ${DRYRUN:-0} == 0 ))
then
  VAL_LOSS=$( grep val_loss $ID.log | tail -1  )
fi

if (( ${#VAL_LOSS} == 0 ))
then
  VAL_LOSS=-1
fi

echo $VAL_LOSS > $VAL_LOSS_FILE

{
  printf $SUMMARY_PREFIX STOP
  date "+ %Y-%m-%d %H:%M %p"
  print_kv SECONDS
  print_kv VAL_LOSS
  print_kv STATUS
} >> $SUMMARY_FILE

echo RUN UNO DONE
exit $APRUN_CODE
