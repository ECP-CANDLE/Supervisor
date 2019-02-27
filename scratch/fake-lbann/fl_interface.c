
#include "fl_interface.h"
#include "fl.h"

#include <mpi.h>

int
fl_interface(int comm, int p)
{
  MPI_Comm c = (MPI_Comm) comm;
  return fl(c, p);
}
