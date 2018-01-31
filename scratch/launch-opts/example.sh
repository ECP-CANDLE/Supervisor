#!/bin/sh
set -eu

# EXAMPLE
# of TURBINE_LAUNCH_OPTIONS on Theta

# Set up LD_LIBRARY_PATH
PY=/projects/Candle_ECP/swift/deps/Python-2.7.12
R=/projects/Candle_ECP/swift/deps/R-3.4.0/lib64/R
LLP=$PY/lib:$R/lib:$LD_LIBRARY_PATH

# Use this Swift/T installation
PATH=/projects/Candle_ECP/swift/2017-12-20/stc/bin:$PATH

# Find myself
THIS=$( dirname $0 )

# Choose one of these:
# 1) Useful example for fast failures
export TURBINE_LAUNCH_OPTIONS="FAIL ME"
# 2) Set thread depth to 2: should not affect hello.swift
# export TURBINE_LAUNCH_OPTIONS="-d 2"

swift-t -m theta -e LD_LIBRARY_PATH=$LLP $THIS/hello.swift

# When the job completes, look at
# TURBINE_OUTPUT/output.txt -
#   contains aprun command used, job output
