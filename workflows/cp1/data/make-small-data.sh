#!/bin/bash
set -eu

# MAKE SMALL DATA

# See the README for data provenance

# INPUT:  data/studies*.txt
#         data/combined_rnaseq_data_combat ORIG
# OUTPUT: data/features-small.txt          FEATURES_SMALL
#         data/rnaseq-small.txt            RNA_SMALL

# Configurable variables:
ORIG=data/combined_rnaseq_data_combat
RNA_SMALL=data/rnaseq-small.txt
FEATURES_SMALL=data/features-small.txt
N_FEATURES=3
N_SAMPLES=5
# End configurable variables.

TAB="$( echo -ne "\t" )" # Tab special character

COLS=$(( $N_FEATURES + 1 )) # Include "Sample" token
cut --delimiter="$TAB" --fields=1-$COLS $ORIG | \
  head --lines 1 > $FEATURES_SMALL
echo "Created: $FEATURES_SMALL"

# Use sed to remove comments, extract each unique study
STUDIES=( $( sed 's/#.*//' data/studies*.txt | sort --unique ) )

# echo ${STUDIES[@]}

# For each study, extract the first COLS columns of the N_SAMPLES rows
for STUDY in ${STUDIES[@]}
do
  grep --max-count=$N_SAMPLES $STUDY $ORIG | \
    cut --delimiter="$TAB" --fields=1-$COLS
done > $RNA_SMALL
echo "Created: $RNA_SMALL"

# Create CCLE_CTRP_2000_1000_features_dummy.txt
#   with feature names
# That is, for each STUDY1, STUDY2, CUTOFF1, CUTOFF2:
#   create STUDY1_STUDY2_CUTOFF1_CUTOFF2_features_small.txt
#   containing some random subset of the features
FEATURES=( $( cut --delimiter="$TAB" --fields=2- $FEATURES_SMALL ) )
echo "Features: ${FEATURES[@]}"

for STUDY1 in ${STUDIES[@]}
do
  for STUDY2 in ${STUDIES[@]}
  do
    if [[ $STUDY1 != $STUDY2 ]]
    then
      FEATURES_LIST=xcorr_data/${STUDY1}_${STUDY2}_2000_1000_features_small.txt
      for F in ${FEATURES[@]}
      do
        if (( $RANDOM % 2 == 0 ))
        then
          echo "rnaseq.$F"
        fi
      done > $FEATURES_LIST
      echo "Created: $FEATURES_LIST"
    fi
  done
done

echo "SUCCESS"
