
#include <stdio.h>
#include <stdlib.h>

#include <mpi.h>

#include "controller.h"
#include "slurp.h"

int
main(int argc, char* argv[])
{
  if (argc != 2)
  {
    printf("provide a program!\n");
    return EXIT_FAILURE;
  }

  char* code = slurp(argv[1]);
  int rc = controller_setup(MPI_COMM_WORLD, code);
  free(code);

  if (!rc)
  {
    printf("FAIL\n");
    return EXIT_FAILURE;
  }

  printf("OK\n");
  return EXIT_SUCCESS;
}
