
/*
  MAIN
  Command line interface to py-eval
*/

#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if MPI_ENABLED == 1
#include <mpi.h>
#endif

#include "io.h"
#include "py-eval.h"
#include "util.h"

static char* usage =
"usage: py-eval [code_files]* expr_file  \n"
"use -   to reset the interpreter        \n"
"use K=V to set an environment variable  \n"
"use 0   for expr_file to print nothing  \n"
"see the README                          \n";

static void mpi_init(void);
static void mpi_finalize(void);

static void options(int argc, char* argv[]);
static void do_commands(int argc, char** argv);

int
main(int argc, char* argv[])
{
  // Set up
  options(argc, argv);
  if (argc == optind) crash(usage);
  mpi_init();
  python_init();

  // Do the commands!
  do_commands(argc, argv);

  // Clean up
  verbose("clean up...");
  python_finalize();
  mpi_finalize();
  exit(EXIT_SUCCESS);
}

#if MPI_ENABLED
MPI_Comm comm;
#endif

static void
mpi_init()
{
  #if MPI_ENABLED
  MPI_Init(NULL, NULL);
  int rank, size;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  verbose("MPI ENABLED: %i/%i", rank, size);
  MPI_Comm_dup(MPI_COMM_WORLD, &comm);
  char s[32];
  sprintf(s, "%i", comm);
  verbose("Set COMM: %s", s);
  setenv("COMM", s, true);
  #endif
}

static void
mpi_finalize()
{
  #if MPI_ENABLED
  verbose("main(): finalize()");
  MPI_Comm_free(&comm);
  MPI_Finalize();
  #endif
}

static void
options(int argc, char* argv[])
{
  int option;
  while ((option = getopt(argc, argv, "hv")) != -1)
    switch (option)
    {
      case 'h':
        puts(usage);
        exit(0);
        break;
      case 'v':
        set_verbose(1);
        break;
      default: crash("option processing");
    }
}

static void do_python_code(char* code_file);
static void do_python_eval(char* expr_file);
static void do_env(char* word);

static void
do_commands(int argc, char** argv)
{
  // Execute command words
  int cw; // current word
  for (cw = optind; cw < argc-1; cw++)
  {
    char* word = argv[cw];
    if (strcmp(word, "-") == 0)
    {
      verbose("reset");
      python_reset();
      continue;
    }
    if (strchr(word, '=') != NULL)
    {
      do_env(word);
      continue;
    }
    do_python_code(word);
  }

  do_python_eval(argv[cw]);
}

static void
do_env(char* word)
{
  char* key   = strtok(word, "=");
  if (key == NULL) crash("bad env: token!");
  char* value = strtok(NULL, "=");
  if (value == NULL) value = "";
  verbose("setenv: %s=%s", key, value);
  setenv(key, value, true);
}

static void
do_python_code(char* code_file)
{
  verbose("file:code: %s", code_file);

  // Read Python code file
  char* code = slurp(code_file);
  if (code == NULL) crash("failed to read: %s", code_file);
  chomp(code);

  // Execute Python code
  bool rc = python_code(code);
  if (!rc) crash("python code failed.");
  free(code);
}

static void
do_python_eval(char* expr_file)
{
  verbose("file:eval: %s", expr_file);

  // Handle exceptional cases
  if (strcmp(expr_file, "-") == 0)
    crash("expr file cannot be -");
  if (strcmp(expr_file, "0") == 0)
    return;

  // Read Python expr file
  char* expr = slurp(expr_file);
  if (expr == NULL) crash("failed to read: %s", expr_file);
  chomp(expr);

  // Do Python eval
  char* result;
  bool rc = python_eval(expr, &result);
  if (!rc) crash("python expr failed.");
  printf("%s\n", result);
  free(expr);
  free(result);
}
