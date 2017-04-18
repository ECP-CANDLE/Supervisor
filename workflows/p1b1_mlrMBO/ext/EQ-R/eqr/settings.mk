
CXXFLAGS = -g -O0 -fPIC -std=c++0x -I/usr/include/tcl -I/usr/share/R/include -I/home/nick/R/x86_64-pc-linux-gnu-library/3.3/RInside/include -I/home/nick/R/x86_64-pc-linux-gnu-library/3.3/Rcpp/include
CPPFLAGS = -I/usr/include/tcl -I/usr/share/R/include -I/home/nick/R/x86_64-pc-linux-gnu-library/3.3/RInside/include -I/home/nick/R/x86_64-pc-linux-gnu-library/3.3/Rcpp/include
LDFLAGS = -L/home/nick/R/x86_64-pc-linux-gnu-library/3.3/RInside/lib -lRInside -L/usr/lib/R/lib -lR -Wl,-rpath -Wl,/usr/lib/R/lib -Wl,-rpath -Wl,/home/nick/R/x86_64-pc-linux-gnu-library/3.3/RInside/lib

TCL_VERSION = 8.6
TCLSH = tclsh8.6
SED_I = sed -i
