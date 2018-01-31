
#pragma once

#include <stdbool.h>

bool python_init(void);

bool python_reset(void);

bool python_code(const char* code);

bool python_eval(const char* expression, char** output);

void python_finalize(void);
