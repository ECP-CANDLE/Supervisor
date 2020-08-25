/*
  UQ NOISE SWIFT
  Main workflow
*/

import assert;
import files;
import io;
import python;
import unix;
import sys;
import string;
import location;
import math;

string FRAMEWORK = "keras";

string xcorr_root = getenv("XCORR_ROOT");
string preprocess_rnaseq = getenv("PREPROP_RNASEQ");
string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");

string exp_id = argv("exp_id");
int benchmark_timeout = toint(argv("benchmark_timeout", "-1"));
string model_name = getenv("MODEL_NAME");

printf("UQ NOISE WORKFLOW.SWIFT");
printf("TURBINE_OUTPUT: " + turbine_output);

float noise_step = 10.0; // Difference between noises
int num_trials = 1;

float num_label_noise= 10; // Number of noise levels to try

float label_noise_array[] = [0:num_label_noise];
int trials[]       = [0:num_trials-1];

foreach level, i in label_noise_array
{
    foreach trial, k in trials
    {
      label_noise = level * noise_step/100;
      run_id = "%0.2f-%01i" % (label_noise, k);
      params = ("{ \"label_noise\" : %f , "  +
                "  \"epochs\"        : 100  } ") %
                (label_noise);
      printf("running: %s", params);
      result = obj(params, run_id);
      printf("result %s : label_noise %0.2f : %s",
             run_id, label_noise, result);
    }
}

