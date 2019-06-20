
#include <stdio.h>
#include <stdlib.h>

#include <mpi.h>

#include "controller.h"

int
main()
{
  MPI_Init(NULL, NULL);
  int rc = controller_setup(MPI_COMM_WORLD, "print(42)");
  if (!rc)
  {
    printf("FAIL\n");
    return EXIT_FAILURE;
  }
  printf("OK\n");
  MPI_Finalize();
  return EXIT_SUCCESS;
}
