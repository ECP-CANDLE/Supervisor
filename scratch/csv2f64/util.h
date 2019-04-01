
#pragma once

#define CHECK(condition, format, args...)         \
  do {                                            \
    if (!(condition)) {                           \
      FAIL(format, ## args);                      \
    }                                             \
  } while (0);

#define FAIL(format, args...)                   \
  do {                                          \
    printf("csv2f64: " format "\n", ## args);   \
    return false;                               \
  } while (0);
