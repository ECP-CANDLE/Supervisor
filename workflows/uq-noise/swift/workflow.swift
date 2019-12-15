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

float noise_step = 3.0; // Difference between noises
int num_trials = 1;

float x_num_noises = 10; // Number of noise levels to try
float y_num_noises = 10; // Number of noise levels to try


float y_noise_levels[] = [0:y_num_noises];
int trials[]       = [0:num_trials-1];

float x_noise_levels[] = [0:x_num_noises];

foreach levelx, i in x_noise_levels
{
  foreach levely, j in y_noise_levels
  {
    foreach trial, k in trials
    {
      y_noise_level = levely * noise_step;
      x_noise_level = levelx * noise_step;
      run_id = "%0.0f-%0.0f-%01i" % (x_noise_level, y_noise_level, k);
      result = obj("{\"x_noise_level\":%f, \"y_noise_level\":%f}" %(x_noise_level, y_noise_level), run_id);
      printf("result %s : x_noise %0.3f y_noise %0.3f : %s", run_id, x_noise_level, y_noise_level, result);
    }
  }
}

