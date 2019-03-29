
#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

const int buffer_size = 1024;

#define CHECK(condition, format, args...)         \
  do {                                            \
    if (!(condition)) {                           \
      FAIL(format, ## args);                      \
    }                                             \
  } while (0);

#define FAIL(format, args...)                   \
  do {                                          \
    printf("csv2f64: " format "\n", ## args);   \
    return false;                               \
  } while (0);

static void usage(void);
static bool convert(const char* input, const char* output);

int
main(int argc, char* argv[])
{
  if (argc != 3)
  {
    usage();
    exit(EXIT_FAILURE);
  }
  char* input  = argv[1];
  char* output = argv[2];

  bool result = convert(input, output);
  CHECK(result, "conversion failed!");

  return EXIT_SUCCESS;    
}



static void
usage()
{
  printf("usage: csv2f64 <input.csv> <output.data>\n");
}

static void
fail(const char* message)
{
  printf("csv2f64: %s\n", message);
}

static bool
convert(const char* input, const char* output)
{
  FILE* fp_i = fopen(input, "r");
  CHECK(fp_i != NULL, "could not read: %s", input);
  FILE* fp_o = fopen(output, "w");
  CHECK(fp_o != NULL, "could not write: %s", output);

  bool result = convert_fps(fp_i, fp_o);
  
  fclose(fp_i);
  fclose(fp_o);

  return result;
}

static bool
convert_fps(FILE* fp_i, FILE* fp_o)
{
  size_t bytes_c;
  bytes = buffer_size * sizeof(char);
  char* chars = malloc(bytes);
  CHECK(chars != NULL, "could not allocate memory: %zi", bytes);
  bytes = buffer_size * sizeof(double);
  double* floats = malloc(bytes);
  CHECK(floats != NULL, "could not allocate memory: %zi", bytes);

  int cols = -1;
  int f = 0; 
  while (true)
  {
    size_t actual = fread(chars, bytes_c, sizeof(char), fp_i);
    for (int i = 0; i < actual, i++)
    {
      
      if (f == buffer_size)
      {
        actual = fwrite(floats, buffer_size, sizeof(double), fp_o);
        CHECK(actual == buffer_size, "write failed!\n");
      }
    }
  }
  
  return true;
}
  
