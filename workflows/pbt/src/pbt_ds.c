
#include <string.h>

#include "dataspaces.h"

#include <assert.h>
#include <limits.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#include "mpi.h"

/**
  Asserts that condition is true, else aborts.
*/
#define CHECK_MSG(condition, args...)                          \
  { if (!(condition)) {                                         \
      printf("CHECK FAILED: %s:%i\n", __FILE__, __LINE__);     \
      printf(args);                                             \
      printf("\n");                                             \
      exit(1); }}

int pbt_ds_init(MPI_Comm comm, int nprocs) {
  int id = 1;
  printf("nprocs: %d\n", nprocs);
  int rc = dspaces_init(nprocs, id, &comm, NULL);
  CHECK_MSG(rc == 0, "dspaces_init failed!");

  return 0;
}

void pbt_ds_finalize() {
  dspaces_finalize();
}

void pbt_ds_define_gdim(const char *var_name, int ndim, uint64_t *gdim) {
  dspaces_define_gdim(var_name, ndim, gdim);
}

void pbt_ds_define_score_dim(int nprocs) {
  uint64_t gdim = nprocs * 2;
  dspaces_define_gdim("scores", 1, &gdim);
}

void pbt_ds_put_score(int rank, double size, double score, MPI_Comm comm) {
  const char* var_name = "scores";
  dspaces_lock_on_write(var_name, &comm);
  uint64_t lb = rank * 2;
  uint64_t ub = lb + 1;
  double data[2] = {size, score};
  int rc = dspaces_put(var_name, 0, sizeof(double), 1, &lb, &ub, data);
  CHECK_MSG(rc == 0, "dspaces_put(%s) failed!\n", var_name);
  rc = dspaces_put_sync();
  CHECK_MSG(rc == 0, "dspaces_put_sync() failed!\n", var_name);
  dspaces_unlock_on_write(var_name, &comm);
}

void pbt_ds_get_all_scores(int nprocs, double* scores, MPI_Comm comm) {
  const char* var_name = "scores";
  dspaces_lock_on_read(var_name, &comm);
  uint64_t lb = 0;
  uint64_t ub = 2 * nprocs - 1;
  int rc = dspaces_get(var_name, 0, sizeof(double), 1,
    &lb, &ub, scores);
  CHECK_MSG(rc == 0, "dspaces_get(%s) failed!\n", var_name);
  dspaces_unlock_on_read(var_name, &comm);
}

void pbt_ds_put_weights(int rank, const char* data, size_t size, MPI_Comm comm) {
  char var_name[50];
  sprintf(var_name, "weights_%d", rank);
  printf("size: %d\n", size);
  printf("Acquiring weights lock\n");
  dspaces_lock_on_write(var_name, &comm);
  printf("Lock acquired\n");
  uint64_t bound = rank;
  printf("start dspaces_put\n");
  int rc = dspaces_put(var_name, 0, size, 1, &bound, &bound, data);
  printf("end dspaces_put\n");
  CHECK_MSG(rc == 0, "dspaces_put(%s) failed!\n", var_name);
  printf("start dspaces_put_sync\n");
  rc = dspaces_put_sync();
  printf("end dspaces_put_sync\n");
  CHECK_MSG(rc == 0, "dspaces_put_sync() failed!\n", var_name);
  dspaces_unlock_on_write(var_name, &comm);
}

void pbt_ds_get_weights(int rank, char* data, size_t size, MPI_Comm comm) {
  char var_name[50];
  sprintf(var_name, "weights_%d", rank);
  dspaces_lock_on_read(var_name, &comm);
  uint64_t bound = rank;
  int rc = dspaces_get(var_name, 0, size, 1, &bound, &bound, data);
  CHECK_MSG(rc == 0, "dspaces_get(%s) failed!\n", var_name);
  dspaces_unlock_on_read(var_name, &comm);
}
