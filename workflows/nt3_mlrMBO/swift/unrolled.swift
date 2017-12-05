
/**
   UNROLLED.SWIFT
   Evaluate an Unrolled Parameter File (UPF)
*/

import io;
import sys;
import files;
import location;
import string;
import R;
import assert;
import python;

assert(strlen(emews_root) > 0, "Set EMEWS_PROJECT_ROOT!");
file upf = input(argv("f"));
string upf_lines[] = file_lines(upf);

string results[];
foreach p, i in results
{
  printf(p);
  // NOTE: obj() is in the obj_*.swift supplied by workflow.sh
  results[j] = obj(p, "%i" % (i));
}
string res = join(results, ";");
printf(res)
