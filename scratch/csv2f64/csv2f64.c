
#include <errno.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "util.h"

const int buffer_size = 32;

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

static bool convert_fps(FILE* fp_i, FILE* fp_o);

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
  size_t bytes_c = buffer_size * sizeof(char);
  char* chars = malloc(bytes_c);
  CHECK(chars != NULL, "could not allocate memory: %zi", bytes_c);
  size_t bytes_f = buffer_size * sizeof(double);
  double* floats = malloc(bytes_f);
  CHECK(floats != NULL, "could not allocate memory: %zi", bytes_f);

  char* c = &chars[0];
  int cols_last = -1;
  int cols = 1;
  int rows = 1;
  int f = 0; // index in floats[]
  int n = 0; // starting offset in chars due to chars from last read
  size_t actual_r = 0;
  size_t actual_w = 0;
  int w = 0; // word start
  while (true)
  {
    actual_r = fread(c, sizeof(char), bytes_c-n, fp_i); 
    printf("actual_r: %zi\n", actual_r);
    if (actual_r == 0) break;
    for (int i = 0; i < actual_r; i++)
    {
      printf("c[i=%i]=%c\n", i, c[i]);
      if (c[i] == ',' || c[i] == '\n')
      {
        errno = 0;
        printf("c[w=%i]=%c\n", w, c[w]);
        double d = strtod(&c[w], NULL);
        CHECK(errno == 0, "bad number on line: %i", rows);
        printf("d: %f\n", d);
        floats[f] = d;
        f++;
        w = i+1;
        if (f == buffer_size)
        {
          actual_w = fwrite(floats, sizeof(double), buffer_size, fp_o);
          CHECK(actual_w == buffer_size, "write failed!\n");
          f = 0;
        }
      }
      if (c[i] == ',')
        cols++;
      if (c[i] == '\n')
      {
        rows++;
        printf("cols=%i cols_last=%i\n", cols, cols_last);
        CHECK(cols == cols_last || cols_last == -1,
              "bad column count on line: %i cols=%i cols_last=%i",
              rows, cols, cols_last);
        cols_last = cols;
        cols = 1;
      }
    }
    n = actual_r - w;
    memcpy(chars, &chars[w], n);
    chars[n] = '\0';
    printf("char start: %s\n", chars);
    c = &chars[n];
    w = 0;
  }
  actual_w = fwrite(floats, sizeof(double), f, fp_o);
  CHECK(actual_w == f, "write failed!\n");
  
  printf("rows: %i cols: %i\n", rows, cols);
  
  free(chars);
  free(floats);
  return true;
}
  
/*
static void
fail(const char* message)
{
  printf("csv2f64: %s\n", message);
}
*/
