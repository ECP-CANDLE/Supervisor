
/*
  CONTROLLER C

  Return codes for all functions:
  Success=1, Failure=0
*/

#include <stdbool.h>

#include <mpi.h>
#include <Python.h>

#include <dlfcn.h>

#include "controller.h"

static int
handle_python_exception(void)
{
  printf("\n");
  printf("PYTHON EXCEPTION:\n");

  #if PY_MAJOR_VERSION >= 3

  PyObject *exc,*val,*tb;
  PyErr_Fetch(&exc,&val,&tb);
  PyObject_Print(exc, stdout, Py_PRINT_RAW);
  printf("\n");
  PyObject_Print(val, stdout, Py_PRINT_RAW);
  printf("\n");

  #else // Python 2

  PyErr_Print();

  #endif

  return 0;
}

#if 0
static int
handle_python_non_string(PyObject* o)
{
  printf("python: expression did not return a string!\n");
  fflush(stdout);
  printf("python: expression evaluated to: ");
  PyObject_Print(o, stdout, 0);
  return 0;
}
#endif

static PyObject* main_module = NULL;
static PyObject* main_dict   = NULL;
static PyObject* local_dict  = NULL;

static bool initialized = false;

static int
python_init(void)
{
/* Loading python library symbols so that dynamic extensions
   don't throw symbol not found error.
   Ref Link: http://stackoverflow.com/questions/29880931/importerror-and-pyexc-systemerror-while-embedding-python-script-within-c-for-pam
*/
  char str_python_lib[32];
#if defined __unix__
  sprintf(str_python_lib, "libpython%d.%d.so", PY_MAJOR_VERSION, PY_MINOR_VERSION);
#elif defined __APPLE__
  sprintf(str_python_lib, "libpython%d.%d.dylib", PY_MAJOR_VERSION, PY_MINOR_VERSION);
#endif
  dlopen(str_python_lib, RTLD_NOW | RTLD_GLOBAL);

  if (initialized) return 1;
  // printf("python: initializing...\n");
  Py_InitializeEx(1);
  main_module  = PyImport_AddModule("__main__");
  if (main_module == NULL) return handle_python_exception();
  main_dict = PyModule_GetDict(main_module);
  if (main_dict == NULL) return handle_python_exception();
  local_dict = PyDict_New();
  if (local_dict == NULL) return handle_python_exception();
  initialized = true;
  return 1;
}

int
controller(MPI_Comm comm, char* code)
{
  if (python_init() == 0) return 0;

  // Store the communicator in the environment for Horovod
  char s[32];
  sprintf(s, "%i", comm);
  printf("Set HOROVOD_COMM: %s\n", s);
  setenv("HOROVOD_COMM", s, 1);

  // Run the Horovod Python program
  PyRun_String(code, Py_file_input, main_dict, local_dict);
  if (PyErr_Occurred()) return handle_python_exception();

  return 1;
}
