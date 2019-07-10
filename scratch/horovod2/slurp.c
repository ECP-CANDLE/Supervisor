
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>

char*
slurp(const char* filename) {
  FILE* file = fopen(filename, "r");
  if (file == NULL) {
    printf("slurp(): could not read from: %s\n", filename);
    return NULL;
  }

  struct stat s;
  int rc = stat(filename, &s);
  if (rc != 0) {
    printf("slurp(): could not stat: %s\n", filename);
    return NULL;
  }

  off_t length = s.st_size;
  char* result = malloc((size_t)length+1);
  if (result == NULL) {
    printf("slurp(): could not allocate memory for: %s\n", filename);
    return NULL;
  }

  char* p = result;
  int actual = (int)fread(p, sizeof(char), (size_t)length, file);
  if (actual != length) {
    printf("could not read all %li bytes from file: %s\n",
           (long) length, filename);
    free(result);
    return NULL;
  }
  result[length] = '\0';

  fclose(file);
  return result;
}
