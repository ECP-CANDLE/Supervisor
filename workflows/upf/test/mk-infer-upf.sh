#!/bin/bash
set -eu

# MK INFER UPF
# Makes a UPF for the infer case

usage()
{
  echo "usage: mk-infer-upf.sh <UPF.JSON> <DIR>..."
  echo "where DIRs contain the data files"
  echo "output will go into UPF.JSON"
}

if (( ${#} < 2 ))
then
  usage
  exit 1
fi

OUTPUT=$1
shift
DIR=( ${*} )

{
  for d in ${DIR[@]}
  do
    export ID=$(      basename $d )
    export MODEL=$(   find $d -name "*.model.h5" )
    export WEIGHTS=$( find $d -name "*.weights.h5" )
    m4 -P < infer-template.json | fmt -w 1024
  done
} > ${OUTPUT}
