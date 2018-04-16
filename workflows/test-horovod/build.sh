#!/bin/bash
set -e

# HOROVOD BUILD SH

CONTROLLER=$HOME/proj/horovod/controller

source $( turbine -C )

set -x

MPICC=$( which mpicc )
MPI=$( dirname $( dirname $MPICC ) )

swig -I$MPI/include -I$CONTROLLER horovod.i

mpicc -c -fPIC $TCL_INCLUDE_SPEC -I$CONTROLLER horovod_wrap.c
mpicc -shared -o libhorovod.so horovod_wrap.o $CONTROLLER/controller.o \
      -l python2.7 
tclsh make-package.tcl > pkgIndex.tcl

stc -r $PWD test-horovod.swift
