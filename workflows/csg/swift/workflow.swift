
/**
   CMP-CV WORKFLOW.SWIFT
*/

import assert;
import io;
import json;
import files;
import string;
import sys;

import candle_utils;
// report_env();

string FRAMEWORK = "pytorch";

// Scan command line
// file   plan = input(argv("plan"));
file model_file = input(argv("models"));
file gparams_file = input(argv("gparams"));
int  benchmark_timeout = string2int(argv("benchmark_timeout", "-1"));

string expid             = getenv("EXPID");
string turbine_output    = getenv("TURBINE_OUTPUT");
string candle_model_type = getenv("CANDLE_MODEL_TYPE");

// Report some key facts:
printf("Cross-Validation: %s", filename(model_file));
system1("date \"WORKFLOW START: +%Y-%m-%d %H:%M\"");

// Read unrolled parameter file
// string plan_lines[] = file_lines(plan);
string model_lines[] = file_lines(model_file);

string gparams_lines[] = file_lines(gparams_file);

// Resultant output values:
string results[];

foreach gparam, j in gparams_lines
{
  // runid = i*1000000 + j;
  runid = j;

  printf("runid: %s", runid);
  printf("gparams: %s", gparam);

  model_name = json_get(gparam, "model_name");
  candle_image = json_get(gparam, "candle_image");
  model_script = "train.sh";

  printf("MODEL: %s", model_name);
  
  results[runid] = obj_container(gparam, expid, repr(runid), model_name, candle_image, model_script);
  
}

