
/*
  UTIL C
*/

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

#include "util.h"

static int verbosity = 0;

void
set_verbose(int level)
{
  verbosity = level;
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
  printf("py-eval: abort: ");
  va_list ap;
  va_start(ap, fmt);
  vprintf(fmt, ap);
  va_end(ap);
  printf("\n");

  exit(EXIT_FAILURE);
}
