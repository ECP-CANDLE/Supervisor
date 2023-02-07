
/**
   UPF WORKFLOW.SWIFT
   Evaluate an Unrolled Parameter File (UPF)
*/

import assert;
import io;
import json;
import files;
import string;
import sys;

import candle_utils;
report_env();

string FRAMEWORK = "keras";

// Scan command line
<<<<<<< Updated upstream
file   upf = input(argv("f"));
=======
file   upf        = input(argv("f"));
>>>>>>> Stashed changes
int    benchmark_timeout = string2int(argv("benchmark_timeout", "-1"));

string model_name     = getenv("MODEL_NAME");
string expid          = getenv("EXPID");
string turbine_output = getenv("TURBINE_OUTPUT");

// Report some key facts:
printf("UPF: %s", filename(upf));
system1("date \"+%Y-%m-%d %H:%M\"");

// Read unrolled parameter file
string upf_lines[] = file_lines(upf);

// Resultant output values:
string results[];

// Evaluate each parameter set
foreach params,i in upf_lines
{
  printf("params: %s", params);
  runid = json_get(params, "id");
  results[i] = obj(params, expid, runid);
  assert(results[i] != "EXCEPTION", "exception in obj()!");
}

// Join all result values into one big semicolon-delimited string
string result = join(results, ";");
// and print it
printf("WORKFLOW RESULT: " + result);
