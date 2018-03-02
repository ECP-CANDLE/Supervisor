
/**
   NT3 UPF WORKFLOW.SWIFT
   Evaluate an Unrolled Parameter File (UPF)
*/

import assert;
import io;
import json;
import files;
import string;
import sys;

system1("date \"+%Y/%m/%d %H:%M\"");

string FRAMEWORK = "keras";

// Scan command line
string obj_param  = argv("obj_param");
file   upf        = input(argv("f"));
int    benchmark_timeout = toint(argv("benchmark_timeout", "-1"));

// Read unrolled parameter file
string upf_lines[] = file_lines(upf);

// Resultant output values:
string results[];

// Evaluate each parameter set
foreach params,i in upf_lines
{
  printf("params: ", params);
  id = json_get(params, "id");
  // NOTE: obj() is in the obj_*.swift supplied by workflow.sh
  results[i] = obj(params, id, obj_param);
}

// Join all result values into one big semicolon-delimited string
string res = join(results, ";");
// and print it
printf(res);
