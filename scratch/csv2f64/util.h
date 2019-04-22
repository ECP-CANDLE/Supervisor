
#pragma once

#include <stdarg.h>

#define MESSAGE(format, args...)                \
  printf("%s: " format "\n", program_name, ## args);

#define CHECK(condition, format, args...)         \
  do {                                            \
    if (!(condition)) {                           \
      FAIL(format, ## args);                      \
    }                                             \
  } while (0);

#define FAIL(format, args...)                   \
  do {                                          \
    MESSAGE(format, ## args);                   \
    return false;                               \
  } while (0);
