#!/bin/zsh
set -eu

# GET TIME
# Extract startup time info from Python log output

FILE=$1

START=$( grep "WORKFLOW START" ${FILE} | zclm 3 )
STOP=$( grep "DO_N_FOLD START" ${FILE} | tail -1 | zclm 7 )

print $(( STOP - START ))
