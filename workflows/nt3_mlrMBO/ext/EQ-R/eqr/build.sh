#!/bin/bash
set -eux

CPPFLAGS=""
CPPFLAGS+="-I/usr/include/tcl "
CPPFLAGS+="-I/usr/share/R/include "
CPPFLAGS+="-I/home/nick/R/x86_64-pc-linux-gnu-library/3.3/RInside/include "
CPPFLAGS+="-I/home/nick/R/x86_64-pc-linux-gnu-library/3.3/Rcpp/include"
CXXFLAGS=$CPPFLAGS

LDFLAGS=""
LDFLAGS+="-L/home/nick/R/x86_64-pc-linux-gnu-library/3.3/RInside/lib -lRInside "
LDFLAGS+="-L/usr/lib/R/lib -lR "
LDFLAGS+="-Wl,-rpath -Wl,/usr/lib/R/lib "
LDFLAGS+="-Wl,-rpath -Wl,/home/nick/R/x86_64-pc-linux-gnu-library/3.3/RInside/lib"

cd "/home/nick/Documents/repos/Supervisor/workflows/p1b1_mlrMBO/ext/EQ-R/eqr"

./bootstrap
CXXFLAGS=$CPPFLAGS CPPFLAGS=$CPPFLAGS LDFLAGS=$LDFLAGS ./configure --prefix="/home/nick/Documents/repos/Supervisor/workflows/p1b1_mlrMBO/ext/EQ-R"
make clean
make install
