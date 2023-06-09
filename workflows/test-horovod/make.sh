#!/bin/bash
set -eu

# HOROVOD MAKE SH

export CONTROLLER=$HOME/proj/horovod/controller

source $( turbine -C )

set -x

MPICC=$( which mpicc )
MPI=$( dirname $( dirname $MPICC ) )

export CC=$MPICC
export CPPFLAGS="-I$MPI/include -I$CONTROLLER $TCL_INCLUDE_SPEC"
export CFLAGS="-fPIC"

make

# swig  horovod.i

# mpicc -c -fPIC $TCL_INCLUDE_SPEC -I$CONTROLLER horovod_wrap.c
# mpicc -shared -o libhorovod.so horovod_wrap.o $CONTROLLER/controller.o \
#       -l python2.7
# tclsh make-package.tcl > pkgIndex.tcl

# stc -r $PWD test-horovod.swift
