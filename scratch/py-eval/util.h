
/*
  UTIL H
  Plain C utilities
*/

#pragma once

void set_verbose(int level);
int  get_verbose(void);
void verbose(char* fmt, ...);
void crash(char* fmt, ...);
