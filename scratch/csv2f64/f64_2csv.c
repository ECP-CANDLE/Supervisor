
/**
   F64 TO CSV
*/

#include <errno.h>
#include <inttypes.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "util.h"

const int buffer_size = 64;

static void usage(void);
static bool convert(const char* input, const char* output);

static char* program_name = "f64_2csv";

int
main(int argc, char* argv[])
{
  if (argc != 5)
  {
    usage();
    exit(EXIT_FAILURE);
  }
  char* input  = argv[1];
  char* output = argv[2];
  int total_rows, total_cols;
  sscanf(argv[3], "%i", &total_rows);
  sscanf(argv[4], "%i", &total_cols);
  
  bool result = convert(input, output, total_rows, total_cols);
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
  printf("usage: f64_2csv <input.csv> <output.data> <total_rows> <total_cols>\n");
}

static bool convert_fps(FILE* fp_i, FILE* fp_o, int total_rows, int total_cols);

static bool
convert(const char* input, const char* output, int total_rows, int total_cols)
{
  FILE* fp_i = fopen(input, "r");
  CHECK(fp_i != NULL, "could not read: %s", input);
  FILE* fp_o = fopen(output, "w");
  CHECK(fp_o != NULL, "could not write: %s", output);

  bool result = convert_fps(fp_i, fp_o, total_rows, total_cols);

  fclose(fp_i);
  fclose(fp_o);

  return result;
}

static inline bool read_doubles(double* data, size_t count, FILE* fp,
                                size_t* actual_r);
static inline bool format_double(int total_cols,
                                 double* floats, 

                                 char* chars,
                                 int* offset,
                                 FILE* fp);

static bool
convert_fps(FILE* fp_i, FILE* fp_o, int total_rows, int total_cols)
{
  size_t bytes_f = buffer_size * sizeof(double);
  double* floats = malloc(bytes_f); // the input buffer
  CHECK(floats != NULL, "could not allocate memory: %zi", bytes_f);
  size_t bytes_c = buffer_size * sizeof(char);
  char* chars = malloc(bytes_c); // the output buffer
  CHECK(chars != NULL, "could not allocate memory: %zi", bytes_c);

  int cols = 1; // current column counter
  int rows = 1; // current row counter
  int f = 0; // index in floats[]
  size_t actual_r = 0; // actual number of items read at last fread
  int offset = 0; // starting offset in chars 
  bool b;
  int i = 0;
  while (true)
  {
    b = read_doubles(&chars[offset], bytes_c-offset, fp_i, &actual_r);
    CHECK(b, "read_doubles() failed!");
    if (actual_r == 0) break;
    for (i = 0; i < actual_r; i++)
    {
      b = format_double(total_cols, bytes_f, chars, bytes_c, &offset,
                        &cols, fp_o);
      CHECK(b, "format_word() failed!");
    }
  }

  // Write out any data left in the buffer
  if (offset != 0)
  {
    size_t actual_w = fwrite(&chars[offset], sizeof(char),
                             buffer_size-offset, fp_o);
    CHECK(actual_w == f, "write failed!\n");
    fprintf(fp_o, "\n");
    rows++;
  }
  
  free(chars);
  free(floats);
  return true;
}

/** Read the next chunk of doubles
    @param actual_r: OUT actual doubles read
    @return True on success, else false
 */
static inline bool
read_doubles(double* data, size_t count, FILE* fp, size_t* actual_r)
{
  size_t actual = fread(data, sizeof(double), count, fp);
  if (actual == 0)
    CHECK(!ferror(fp), "read failed!");
  *actual_r = actual;
  return true;
}

/** Convert the word (word_start) into a double and possibly write it out
    @param floats IN/OUT Where to add the converted double
    @param f IN/OUT The working index into floats
    @return True on success, else false
*/
static inline bool
format_double(int total_cols, double* floats,
	      char* chars, int bytes_c, int* offset,
	      int* cols, FILE* fp)
{
  char* c = &chars[*offset];
  int max = 20;
  char* format = "%f";
  int actual_c = strfromd(c, max, format, fp);
  assert(actual_c < max);

  *offset += *offset + actual_c;

  *cols = *cols + 1;
  if (*cols == total_cols)
  {
    chars[*offset] = '\n';
    *offset = *offset + 1;
  }

  if (*offset > bytes_c - max)
  {
    int actual_w = fwrite(chars, sizeof(char), offset, fp);
    assert(actual_w == offset);
    *offset = 0;
  }

  return true;
}

