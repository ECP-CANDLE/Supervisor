#!/bin/bash
set -eu

# MAKE SMALL DATA

# See the README for data provenance

# INPUT:  data/studies*.txt
#         data/combined_rnaseq_data_combat
# OUTPUT: data/features-small.txt
#         data/rnaseq-small.txt

# Configurable variables:
ORIG=data/combined_rnaseq_data_combat
SMALL=data/rnaseq-small.txt
N_FEATURES=3
N_SAMPLES=5
# End configurable variables.

TAB="$( echo -ne "\t" )" # Tab special character

COLS=$(( $N_FEATURES + 1 )) # Include "Sample" token
cut -d "$TAB" -f 1-$COLS $ORIG | head -1 > data/features-small.txt

STUDIES=( $( sed 's/#.*//' data/studies*.txt | sort -u ) ) # Remove comments

# echo ${STUDIES[@]}

for STUDY in ${STUDIES[@]}
do
  grep --max-count=$N_SAMPLES $STUDY $ORIG | cut -d "$TAB" -f 1-$COLS
done > $SMALL
