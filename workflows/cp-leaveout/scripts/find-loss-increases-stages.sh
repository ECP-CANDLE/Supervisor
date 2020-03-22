#!/bin/bash

# FIND LOSS INCREASES STAGES SH

# Runs find-loss-increases for each individual stage

# Input:  Provide an experiment directory
# Output: Information printed to screen (pipe this into less)

THIS=$( readlink --canonicalize $( dirname $0 ) )

SUPERVISOR=$( readlink --canonicalize $THIS/../../.. )

export PYTHONPATH+=:$SUPERVISOR/workflows/common/python

for S in 2 3 4 5
do
  python3 -u $THIS/find-loss-increases.py $* -S $S
  echo
done
