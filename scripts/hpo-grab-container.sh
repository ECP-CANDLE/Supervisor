#!/bin/bash
set -eu

# HPO GRAB CONTAINER SH
# Copy key outputs into Hall of Fame
# After running this script, the user should post to GitHub
# See README.adoc

THIS=$(       realpath $( dirname $0 ) )
SUPERVISOR=$( realpath $THIS/.. )
export THIS

source $SUPERVISOR/workflows/common/sh/utils.sh

SIGNATURE -H "See README.adoc" \
          HOF MODEL SIZE PARAMS D1 D2 DATASET RANK - ${*}

# The Hall of Fame and experiment directory must exist!
for V in HOF D1 D2
do
  if [[ ! -d ${!V} ]]
  then
    abort "Does not exist: ${V}=${!V}"
  fi
done

OUTPUT=$HOF/$MODEL/$DATASET/$SIZE
mkdir -pv $OUTPUT

# Write some metadata about this run
{
  echo "METADATA"
  printf "DATE="
  date "+%Y-%m-%d %H:%M"
  echo "USER=$USER"
  printf "HOSTNAME="
  hostname
  show MODEL SIZE PARAMS D1 D2 DATASET RANK
  grep -h "num_iter:\|num_pop:" $D1/out/out-*.txt
} | tee $OUTPUT/metadata.txt

# Extract the HPO results into a CSV
$THIS/hpo_table_container.py -v -p $PARAMS $D2 $D2/hpo.csv
cp -v $D2/hpo.csv $OUTPUT

# Copy over some other results files
FILES=( best-$RANK.json
        deap-$RANK.log
        fitness-$RANK.txt
        fitnesses-$RANK.txt
        *param_space*.json
      )
if ! cp -uv --backup=numbered ${FILES[@]} $OUTPUT
then
  abort "Could not copy files from $PWD"
fi
