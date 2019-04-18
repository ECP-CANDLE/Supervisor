
#include <errno.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "util.h"

const int buffer_size = 8;

static void usage(void);
static bool convert(const char* input, const char* output);

static char* program_name = "csv2f64";

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
  if (!result)
  {
    MESSAGE("conversion failed!");
    return EXIT_FAILURE;
  }

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

  int cols_last = -1;
  int cols = 1;
  int rows = 1;
  int f = 0; // index in floats[]
  int n = 0; // starting offset in chars due to chars from last read
  size_t actual_r = 0;
  size_t actual_w = 0;
  int length = 0; // the length of our current data (n+actual_r)
  int w = 0; // word start
  bool data_on_line = false;
  while (true)
  {
    actual_r = fread(&chars[n], sizeof(char), bytes_c-n, fp_i);
    printf("actual_r: %zi\n", actual_r);
    if (actual_r == 0)
    {
      CHECK(!ferror(fp_i), "read failed!");
      break;
    }

    length = n + actual_r;
    for (int i = 0; i < length; i++)
    {
      printf("chars[i=%i]='%c'\n", i, chars[i]);
      if (chars[i] == ' ' || chars[i] == '\t') continue;
      if (chars[i] == '\n' && ! data_on_line) continue; // blank line
      data_on_line = true;
      if (chars[i] == ',' || chars[i] == '\n')
      {
        if (i == w)
          // Word length is 0 and not blank line - error
          FAIL("bad text on line: %i column: %i", rows, i-n+1);
        errno = 0;
        printf("chars[w=%i]=%c\n", w, chars[w]);
        double d = strtod(&chars[w], NULL);
        CHECK(errno == 0, "bad number on line: %i", rows);
        floats[f] = d;
        printf("f[%i]=%f\n", f, floats[f]);
        f++;
        w = i+1;
        if (f == buffer_size)
        {
          actual_w = fwrite(floats, sizeof(double), buffer_size, fp_o);
          CHECK(actual_w == buffer_size, "write failed!\n");
          f = 0;
        }
      }
      if (chars[i] == ',')
        cols++;
      if (chars[i] == '\n')
      {
        rows++;
        printf("cols=%i cols_last=%i\n", cols, cols_last);
        CHECK(cols == cols_last || cols_last == -1,
              "bad column count on line: %i cols=%i cols_last=%i",
              rows, cols, cols_last);
        cols_last = cols;
        cols = 1;
        data_on_line = false;
      }
    }
    // Out of space in chars
    printf("copy: w=%i\n", w);
    n = length - w;
    memcpy(chars, &chars[w], n);
    chars[n] = '\0';
    printf("char start: '%s'\n", chars);
    w = 0;
  }
  actual_w = fwrite(floats, sizeof(double), f, fp_o);
  CHECK(actual_w == f, "write failed!\n");

  printf("rows: %i cols: %i\n", rows, cols);

  free(chars);
  free(floats);
  return true;
}
