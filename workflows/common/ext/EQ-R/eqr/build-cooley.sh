#!/bin/bash -f
set -eu

if [[ ! -f configure ]] || [[ configure.ac -nt configure ]]
then
  ./bootstrap
fi

source settings-cooley.sh

# Add Tcl
PATH=$TCL/bin:$PATH

# Add G++ 4.8
PATH=/soft/compilers/gcc/4.8.1/bin:$PATH
LD_LIBRARY_PATH=/soft/compilers/gcc/4.8.1/lib64:$LD_LIBRARY_PATH
LD_LIBRARY_PATH=/soft/compilers/gcc/4.8.1/lib:$LD_LIBRARY_PATH

./configure --prefix=$PWD/..

make -j
