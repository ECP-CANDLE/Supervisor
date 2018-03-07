#!/bin/bash -l

usage()
{
  echo "usage: test.sh <N>"
  echo "N is the test number"
}

if [[ ${#} != 1 ]]
then
  usage
  exit 1
fi

N=$1

THIS=$( dirname $0 )

swift-t -n 3 -I $THIS -r $THIS test-$N.swift
