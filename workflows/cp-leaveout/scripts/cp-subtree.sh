#!/bin/zsh -f
set -eu

# CP SUBTREE SH
# Make a subset of the existing experiment tree
# Selects N leaf nodes at stage STAGE
# Copies those leaf nodes and their parents into output directory OUT

THIS=$( realpath $( dirname $0 ) )

SUPERVISOR=$( realpath $THIS/../../.. )
alias shopt=:
source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "Provide DIR OUT STAGE N" \
          DIR OUT STAGE N - ${*}

EXP_ID=${DIR:t}

mkdir -pv $OUT/$EXP_ID/run
OUT=$( realpath $OUT )

cd $DIR/run

# Make pattern for grep on directory names
P=()
PATTERN=""

# Don't forget stage 0 == "1."
repeat $(( STAGE + 1 )) P+=( . )
# Join array P with separator . (dot)
PATTERN="^${(j:.:)P}\$"

# Pull out N random directories that match pattern
NODES=( $( ls | grep "$PATTERN" | shuf -n $N ) )

for NODE in $NODES
do
  if [[ -d $OUT/$NODE ]] continue
  print "copy: $NODE ..."
  cp -r $NODE $OUT/$EXP_ID/run
  while true
  do
    # Parent node: chop off last 2 characters
    NODE=${NODE[1,-3]}
    if (( ${#NODE} == 1 )) break
    if [[ -d $OUT/$NODE ]] break
    print "copy: $NODE ..."
    cp -r $NODE $OUT/$EXP_ID/run
  done
done
