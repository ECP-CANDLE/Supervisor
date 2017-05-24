# R system-wide install where libraries and includes have
# a different parent and optional packages are installed within
# a user's home directory (e.g. Ubuntu 16.04)

# R_INCLUDE=/usr/share/R/include
# R_LIB=/usr/lib/R/lib
# R_LOCAL_LIB=$HOME/R/x86_64-pc-linux-gnu-library/3.3
# R_INSIDE=$R_LOCAL_LIB/RInside
# RCPP=$R_LOCAL_LIB/Rcpp

R=/home/wozniak/Public/sfw/x86_64/R-3.2.3-gcc-4.8.1/lib64/R
R_INCLUDE=$R/include
R_LIB=$R/lib
R_LIBRARY=$R/library
# R_LOCAL_LIB=$HOME/R/x86_64-pc-linux-gnu-library/3.3
# R_LIB=$R/lib
R_INSIDE=$R_LIBRARY/RInside
RCPP=$R_LIBRARY/Rcpp

# R system-wide install where libraries and includes
# are under a common system wide home directory, and 3rd party
# packages are installed in a user's home directory.
# R_HOME=/software/R-3.2-el6-x86_64/lib64/R
# R_INCLUDE=$R_HOME/include
# R_LIB=$R_HOME/lib
# R_LOCAL_LIB=$HOME/R/x86_64-unknown-linux-gnu-library/3.2
# R_INSIDE=$R_LOCAL_LIB/RInside
# RCPP=$R_LOCAL_LIB/Rcpp

# R install where libraries and includes are under
# a common directory e.g. a local install of R in a
# user's home directory.
# R_HOME=$HOME/sfw/R-3.0.1
# R_INCLUDE=$R_HOME/lib/R/include
# R_LIB=$R_HOME/lib/R/lib
# R_INSIDE=$R_HOME/lib/R/library/RInside
# RCPP=$R_HOME/lib/R/library/Rcpp

# OSX - R installed in /Library/Framework/R with
# Rcpp and RInside installed beneath that
# R_HOME=/Library/Frameworks/R.framework
# R_INCLUDE=$R_HOME/Resources/include
# R_LIB=$R_HOME/Resources/lib
# R_INSIDE=$R_HOME/Resources/RInside
# RCPP=$R_HOME/Resources/Rcpp

#system-wide tcl
# TCL_INCLUDE=/usr/local/include/tcl
# TCL_LIB=/usr/local/lib
# TCL_LIBRARY=tcl8.6

TCL=/home/wozniak/Public/sfw/x86_64/tcl-8.6.6-global-gcc-4.8.1
TCL_INCLUDE=$TCL/include
TCL_LIB=$TCL/lib
TCL_LIBRARY=tcl8.6

# a local tcl
# TCL_INCLUDE=$HOME/sfw/tcl-8.6.0/include
# TCL_LIB=$HOME/sfw/tcl-8.6.0/lib
# TCL_LIBRARY=tcl8.6

CPPFLAGS=""
CPPFLAGS+="-I$TCL_INCLUDE "
CPPFLAGS+="-I$R_INCLUDE "
CPPFLAGS+="-I$RCPP/include "
CPPFLAGS+="-I$R_INSIDE/include "
CXXFLAGS=$CPPFLAGS

LDFLAGS=""
LDFLAGS+="-L$R_INSIDE/lib -lRInside "
LDFLAGS+="-L$R_LIB -lR "
LDFLAGS+="-L$TCL_LIB -l$TCL_LIBRARY "
LDFLAGS+="-Wl,-rpath -Wl,$TCL_LIB "
LDFLAGS+="-Wl,-rpath -Wl,$RCPP/lib "
LDFLAGS+="-Wl,-rpath -Wl,$R_INSIDE/lib"

export CPPFLAGS CXXFLAGS LDFLAGS
