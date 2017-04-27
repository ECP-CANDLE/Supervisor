#!/bin/zsh -f
set -eu

if [[ ! -f configure ]] || [[ configure.ac -nt configure ]]
then
  ./bootstrap
fi

source settings.sh

./configure --prefix=$PWD/..

make -j
