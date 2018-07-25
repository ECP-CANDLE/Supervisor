
/**
   EQR.i
   SWIG interface file
   Generates Tcl bindings in *_wrap.cxx
*/

%module eqr

%include <std_string.i>

%include "EQR.h"

// Paste this code into the output *_wrap.cxx file
%{
  #include "EQR.h"
%}
