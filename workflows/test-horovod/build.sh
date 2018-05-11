#!/bin/bash
set -e

# HOROVOD BUILD SH

# Cori:
PATH=/global/homes/w/wozniak/Public/sfw/mpich-3.2.1/bin:$PATH
PATH=/global/homes/w/wozniak/Public/sfw/tcl-8.6.6/bin:$PATH
PATH=$HOME/Public/sfw/login/swift-t-2018-04-16/turbine/bin:$PATH

# USER: set the Horovod location here:
HOROVOD=$HOME/proj/horovod

CONTROLLER=$HOROVOD/controller

source $( turbine -C )

set -x

MPICC=$( which mpicc )
MPI=$( dirname $( dirname $MPICC ) )

swig -I$MPI/include -I$CONTROLLER horovod.i

mpicc -c -fPIC $TCL_INCLUDE_SPEC -I$CONTROLLER horovod_wrap.c
mpicc -shared -o libhorovod.so horovod_wrap.o $CONTROLLER/controller.o \
      -l python2.7
tclsh make-package.tcl > pkgIndex.tcl
