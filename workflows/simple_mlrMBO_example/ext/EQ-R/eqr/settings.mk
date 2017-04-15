
CXXFLAGS = -g -O0 -fPIC -std=c++0x -I/usr/local/include -I/Library/Frameworks/R.framework/Versions/3.3/Resources/include -I/Users/jozik/Library/R/3.3/library/Rcpp/include -I/Users/jozik/Library/R/3.3/library/RInside/include 
CPPFLAGS = -I/usr/local/include -I/Library/Frameworks/R.framework/Versions/3.3/Resources/include -I/Users/jozik/Library/R/3.3/library/Rcpp/include -I/Users/jozik/Library/R/3.3/library/RInside/include 
LDFLAGS = -L/Users/jozik/Library/R/3.3/library/RInside/lib -lRInside -L/Library/Frameworks/R.framework/Versions/3.3/Resources/lib -lR -L/usr/local/lib -ltcl8.6 -Wl,-rpath -Wl,/usr/local/lib -Wl,-rpath -Wl,/Library/Frameworks/R.framework/Versions/3.3/Resources/lib -Wl,-rpath -Wl,/Users/jozik/Library/R/3.3/library/RInside/lib

TCL_VERSION = 8.6
TCLSH = tclsh8.6
SED_I = sed -i ''
