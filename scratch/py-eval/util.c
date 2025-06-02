
/*
  UTIL C
*/

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#include "util.h"

// verbosity==0 means be silent
static int verbosity = 0;

void
set_verbose(int level)
{
  verbosity = level;
}

int
get_verbose()
{
  return verbosity;
}

void
verbose(char* fmt, ...)
{
  if (verbosity == 0) return;
  char b[1024];
  char* p = &b[0];
  p += sprintf(p, "py-eval: ");
  va_list ap;
  va_start(ap, fmt);
  p += vsprintf(p, fmt, ap);
  va_end(ap);
  puts(b);
  fflush(stdout);
}

void
crash(char* fmt, ...)
{
  printf("py-eval: crash: ");
  va_list ap;
  va_start(ap, fmt);
  vprintf(fmt, ap);
  va_end(ap);
  printf("\n");

  exit(EXIT_FAILURE);
}
