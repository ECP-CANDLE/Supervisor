
/*
  HOROVOD I
  SWIG interface file
*/

%module horovod

%include "controller.h"

%{
typedef int MPI_Comm;
#include "controller.h"
%}

typedef int MPI_Comm;
