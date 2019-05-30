
#include <stdio.h>

#include <mpi.h>

#include "controller.h"

int
main()
{
  MPI_Init(NULL, NULL);
  printf("OK\n");
  MPI_Finalize();
  return 0;
}
