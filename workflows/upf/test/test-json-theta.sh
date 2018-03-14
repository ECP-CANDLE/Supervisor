#!/bin/sh
set -eu

# TEST JSON THETA

export PROJECT=ecp-testbed-01 QUEUE=debug-cache-quad

PP=/projects/Candle_ECP/swift/2018-03-07/turbine/py
PY=/projects/Candle_ECP/swift/deps/Python-2.7.12
R=/projects/Candle_ECP/swift/deps/R-3.4.0/lib64/R
LLP=$PY/lib:$R/lib # :$LD_LIBRARY_PATH

STC=/projects/Candle_ECP/swift/2018-03-07/stc
PATH=$STC/bin:$PY/bin:$PATH

swift-t -p -m theta -O0 \
        -e LD_LIBRARY_PATH=$LLP \
        -e PYTHONPATH=$PP \
        -e PATH=$PATH \
        -e PYTHONHOME=$PY \
        test-json.swift
