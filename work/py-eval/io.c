
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

char*
slurp(const char* filename)
{
  FILE* file = fopen(filename, "r");
  if (file == NULL)
  {
    printf("slurp(): could not read from: %s\n", filename);
    return NULL;
  }

  struct stat s;
  int rc = stat(filename, &s);
  if (rc != 0)
  {
    printf("slurp(): could not stat: %s\n", filename);
    return NULL;
  }

  size_t length = s.st_size;
  char* result = malloc(length+1);
  if (result == NULL)
  {
    printf("slurp(): could not allocate memory for: %s\n", filename);
    return NULL;
  }

  char* p = result;
  size_t actual = fread(p, sizeof(char), length, file);
  if (actual != length)
  {
    printf("could not read all %zi bytes from file: %s\n",
           length, filename);
    free(result);
    return NULL;
  }
  result[length] = '\0';

  fclose(file);
  return result;
}

void
chomp(char* s)
{
  size_t length = strlen(s);
  if (s[length-1] == '\n')
    s[length-1] = '\0';
}
