#!/bin/bash
set -eu

# HPO GRAB SH
# Copy key outputs into Hall of Fame
# See README.adoc

THIS=$(       realpath $( dirname $0 ) )
SUPERVISOR=$( realpath $THIS/.. )
export THIS

source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "See README.adoc" \
          HOF MODEL SIZE PARAMS D1 D2 DATASET RANK - ${*}

for V in HOF D1 D2
do
  if [[ ! -d ${!V} ]]
  then
    abort "Does not exist: ${V}=${!V}"
  fi
done

OUTPUT=$HOF/$MODEL/$DATASET/$SIZE
mkdir -pv $OUTPUT

{
  echo "METADATA"
  printf "DATE="
  date "+%Y-%m-%d %H:%M"
  echo "USER=$USER"
  printf "HOSTNAME="
  hostname
  show MODEL SIZE PARAMS D1 D2 DATASET RANK
} > $OUTPUT/metadata.txt

grep -h "num_iter:\|num_pop:" $D1/out/out-*.txt

hpo_table.py -v -p $PARAMS $D2 $D2/hpo.csv
cp -v $D2/hpo.csv $OUTPUT

pushd $D1 > /dev/null
FILES=( best-$RANK.json
        deap-$RANK.log
        fitness-$RANK.txt
        fitnesses-$RANK.txt
      )
if ! cp -uv --backup=numbered ${FILES[@]} $OUTPUT
then
  abort "Could not copy files from $PWD"
fi
popd > /dev/null
