#!/bin/bash
set -eu

if [[ ${#} != 1 ]]
then
  echo "Specify a Swift script!"
  exit 1
fi
SCRIPT=$1

THIS=$( readlink --canonicalize $( dirname $0 ) )
SV=$(   readlink --canonicalize $THIS/../.. )
source $SV/workflows/common/sh/env-summit-tf-2.4.1.sh

# Basic Swift/T environment settings:
export PROJECT=MED106
export PPN=2
PROCS=2

which swift-t

set -x
swift-t -m lsf -n $PROCS \
       $SCRIPT
