module load gcc
export PATH=$PATH:/ccs/home/wozniak/Public/sfw/swig-3.0.2/bin

# TITAN BUILD SETTINGS

R_HOME=/sw/xk6/r/3.3.2/sles11.3_gnu4.9.3x/lib64/R
R_INCLUDE=$R_HOME/include
R_LIB=$R_HOME/lib
R_INSIDE=$R_HOME/library/RInside
RCPP=$R_HOME/library/Rcpp

#system-wide tcl
TCL=/ccs/home/wozniak/Public/sfw/tcl-8.6.2
TCL_INCLUDE=$TCL/include
TCL_LIB=$TCL/lib
TCL_LIBRARY=tcl8.6
export PATH=$PATH:/ccs/home/wozniak/Public/sfw/tcl-8.6.2/bin

CPPFLAGS=""
CPPFLAGS+="-I$TCL_INCLUDE "
CPPFLAGS+="-I$R_INCLUDE "
CPPFLAGS+="-I$RCPP/include "
CPPFLAGS+="-I$R_INSIDE/include "
CXXFLAGS=$CPPFLAGS

LDFLAGS=""
LDFLAGS+="-L$R_INSIDE/lib -lRInside "
LDFLAGS+="-L$R_LIB -lR -lRblas "
LDFLAGS+="-L$TCL_LIB -l$TCL_LIBRARY "
LDFLAGS+="-Wl,-rpath -Wl,$TCL_LIB "
LDFLAGS+="-Wl,-rpath -Wl,$R_LIB "
LDFLAGS+="-Wl,-rpath -Wl,$R_INSIDE/lib"

export CPPFLAGS CXXFLAGS LDFLAGS
