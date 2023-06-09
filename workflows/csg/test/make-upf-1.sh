#!/bin/zsh



OUTPUT=$1

# Use ZSH for range operation

EPOCHS_MIN=10
EPOCHS_MAX=20
BATCH_SIZE_MIN=5
BATCH_SIZE_MAX=7


for EPOCHS in {$EPOCHS_MIN..$EPOCHS_MAX}
do
  for BATCH_SIZE in {$BATCH_SIZE_MIN..$BATCH_SIZE_MAX}
  do
    BS2=$(( 2 ** BATCH_SIZE ))
    echo "{"
    echo "\"epochs\": $EPOCHS,"
    echo "\"batch_size\": $BATCH_SIZE,"
    echo "MORE_PARAMS"
    echo "}"
  done
done > $OUTPUT
