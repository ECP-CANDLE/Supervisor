
#include <getopt.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "io.h"
#include "py-eval.h"

static char* usage =
"usage: py-eval [code_files]* expr_file\n"
"use - to reset the interpreter\n"  
"see the README\n";

static bool verbose = false;

static void crash(char* fmt, ...);
static void do_python_code(char* code_file);
static void do_python_eval(char* expr_file);

static void options(int argc, char* argv[]);

int
main(int argc, char* argv[])
{
  if (argc == 1) crash(usage);

  options(argc, argv);
  python_init();

  int cf; // current file
  
  for (cf = optind; cf < argc-1; cf++)
  {
    char* code_file = argv[cf];
    if (strcmp(code_file, "-") == 0)
    {
      python_reset();
      continue;
    }
    do_python_code(code_file);
  }

  do_python_eval(argv[cf]);
  
  // Clean up
  python_finalize();
  exit(EXIT_SUCCESS);
}

static int
options(int argc, char* argv[])
{
  int opt;
  while ((opt = getopt(argc, argv, "v")) != -1)
  {
    switch (opt)
    {
      case 'v': verbose = true; break;
      default: crash("bad option: %c", opt);
    }
  }
  return optind;
}

static void
do_python_code(char* code_file)
{
  char* code = slurp(code_file);
  chomp(code);
  if (code == NULL) crash("failed to read: %s", code_file);
  bool rc = python_code(code);
  free(code);
  if (!rc) crash("python code failed.");
}

static void
do_python_eval(char* expr_file)
{
   // Read Python expr file
  if (strcmp(expr_file, "-") == 0)
    crash("expr file cannot be -");
  char* expr = slurp(expr_file);
  if (expr == NULL) crash("failed to read: %s", expr_file);
  chomp(expr);

  // Do Python eval
  char* result;
  bool rc = python_eval(expr, &result);
  free(expr);
  if (!rc) crash("python expr failed.");
  printf("%s\n", result);
}

static void
crash(char* fmt, ...)
{
  printf("py-eval: ");
  va_list ap;
  va_start(ap, fmt);
  vprintf(fmt, ap);
  va_end(ap);
  printf("\n");
  
  exit(EXIT_FAILURE);
}
