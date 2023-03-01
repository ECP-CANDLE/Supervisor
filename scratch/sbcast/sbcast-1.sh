#!/bin/bash
set -eu

# Add Swift/T to PATH
ROOT=/autofs/nccs-svm1_home1/wozniak/Public/sfw/frontier
SWIFT=$ROOT/swift-t/2023-02-23
PATH=$SWIFT/stc/bin:$PATH
PATH=$SWIFT/turbine/bin:$PATH
# Add Python to PATH
PY=/gpfs/alpine/med106/proj-shared/hm0/candle_tf_2.10
PATH=$PY/bin:$PATH

# Set up data
EXPORTED_DATA_DIR="/ccs/home/hm0/med106_proj/Benchmarks/Pilot1/Uno"
EXPORTED_DATA_FILE="top_21_auc_1fold.uno.h5"

# Scheduler settings
export PROJECT=MED106
export TURBINE_PRELAUNCH="sbcast -f -F 8 $EXPORTED_DATA_DIR/$EXPORTED_DATA_FILE /dev/shm/$EXPORTED_DATA_FILE"

# Run the workflow!
swift-t -m slurm sbcast-1.swift
