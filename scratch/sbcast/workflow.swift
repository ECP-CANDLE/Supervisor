
import io;
import sys;

app ls(string dir)
{
  "ls" dir ;
}

local_prefix = "/dev/shm";

printf("local_prefix: '%s'", local_prefix) =>
  ls(local_prefix);
