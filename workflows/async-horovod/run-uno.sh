#!/bin/bash
set -eu

# RUN UNO SH

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
OUTPUT_FILE=$( printf "$OUTPUT/val_loss-%04i.txt" $ID )

cd $UNO_HOME

E=""
if (( ${DRYRUN:-0} == 1 ))
then
  E=echo
  # Make a number out of the arguments:
  # Hash the arguments, extract first 8 bytes
  H=$( echo $ARGTEXT | md5sum | head --bytes 8 )
  # Treat as hex value and take mod 10
  VAL_LOSS=$(( 0x$H % 10 ))
  sleep $VAL_LOSS
  echo $VAL_LOSS > $OUTPUT_FILE
fi

$E aprun -N 1 -n $PARALLELISM \
      -cc depth -d 128 -j 4 -b \
      python $UNO_HOME/uno_baseline_keras2.py \
      --epochs 1 \
      --cache uno-landmark.cache-1 \
      -v --warmup_lr \
      --optimizer $KERAS_OPTIMIZER \
      --lr $LEARNING_RATE \
      -l $OUTPUT/uno-$ID.log \
      --use_landmark_genes \
      --cp \
      --save_path save \
      --model_file uno-adam-0.0000001
  
if (( ${DRYRUN:-0} == 0 ))
then
  grep val_loss $ID.log | tail -1 | tee $OUTPUT_FILE
fi
