
#include <stdio.h>

#include <mpi.h>

int
fl(MPI_Comm comm, int p)
{
  printf("fl: running: %i\n", p);
  MPI_Barrier(comm);
  printf("fl: barrier ok\n");
  return p*2;
}
