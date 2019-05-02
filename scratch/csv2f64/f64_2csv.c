
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
                                 char* chars, int* offset,
                                 FILE* fp);
static inline bool update_rows_cols(char c,
                                    int total_cols, 
				    int total_rows);

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
      b = format_word(bytes_f, chars, &offset, fp_out);
      CHECK(b, "format_word() failed!");
    }
  }

  // Write out any data left in the buffer
  if (offset != 0)
  {
    size_t actual_w = fwrite(&chars[offset], sizeof(char),
                             buffer_size-offset, fp_o);
    CHECK(actual_w == f, "write failed!\n");
    fprintf(fp_out, "\n");
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
convert_word(int rows, const char* word_start,
	     double* floats, int* f, FILE* fp)
{
  int fi = *f;
  errno = 0;
  floats[fi] = strtod(word_start, NULL);
  CHECK(errno == 0, "bad number on line: %i", rows);
  fi++;

  if (fi == buffer_size)
  {
    size_t actual = fwrite(floats, sizeof(double), buffer_size, fp);
    CHECK(actual == buffer_size, "write failed!");
    fi = 0;
  }
  *f = fi;
  return true;
}

/** Update the row and column counters
    All pointer parameters are IN/OUT
    @return True on success, else false
 */
static inline bool
update_rows_cols(char c, int* cols, int* cols_last,
		 int* rows, bool* data_on_line)
{
  if (c == ',')
    (*cols)++;
  if (c == '\n')
  {
    (*rows)++;
    CHECK(*cols == *cols_last || *cols_last == -1,
          "bad column count on line: %i cols=%i cols_last=%i",
          *rows, *cols, *cols_last);
    *cols_last = *cols;
    *cols = 1;
    *data_on_line = false;
  }
  return true;
}
