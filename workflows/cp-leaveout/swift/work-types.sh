#!/bin/zsh
set -eu

pt ~/sfw/swift-t/stc/bin
pt ~/sfw/swift-t/turbine/bin

export TURBINE_DB_WORKERS=2

set -x
swift-t -O 0 -l -n 6 work-types.swift
