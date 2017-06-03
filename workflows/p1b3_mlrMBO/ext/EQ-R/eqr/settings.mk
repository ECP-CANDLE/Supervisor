
CXXFLAGS = -g -O0 -fPIC -std=c++0x -I/global/u1/w/wozniak/Public/sfw/tcl-8.6.6/include -I/global/homes/w/wozniak/Public/sfw/R-3.4.0/lib64/R/include -I/global/homes/w/wozniak/Public/sfw/R-3.4.0/lib64/R/library/Rcpp/include -I/global/homes/w/wozniak/Public/sfw/R-3.4.0/lib64/R/library/RInside/include 
CPPFLAGS = -I/global/u1/w/wozniak/Public/sfw/tcl-8.6.6/include -I/global/homes/w/wozniak/Public/sfw/R-3.4.0/lib64/R/include -I/global/homes/w/wozniak/Public/sfw/R-3.4.0/lib64/R/library/Rcpp/include -I/global/homes/w/wozniak/Public/sfw/R-3.4.0/lib64/R/library/RInside/include 
LDFLAGS = -L/global/homes/w/wozniak/Public/sfw/R-3.4.0/lib64/R/library/RInside/lib -lRInside -L/global/homes/w/wozniak/Public/sfw/R-3.4.0/lib64/R/lib -lR -lRblas -L/global/u1/w/wozniak/Public/sfw/tcl-8.6.6/lib -ltcl8.6 -Wl,-rpath -Wl,/global/u1/w/wozniak/Public/sfw/tcl-8.6.6/lib -Wl,-rpath -Wl,/global/homes/w/wozniak/Public/sfw/R-3.4.0/lib64/R/lib -Wl,-rpath -Wl,/global/homes/w/wozniak/Public/sfw/R-3.4.0/lib64/R/library/RInside/lib

TCL_VERSION = 8.6
TCLSH = tclsh8.6
SED_I = sed -i
