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
import json;

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

float std_dev_step = 0.05; // Difference between noises
int num_trials = 2;

float num_std_dev_noise= 20; // Number of noise levels to try

float std_dev_array[] = [0:num_std_dev_noise];
int trials[]       = [0:num_trials-1];

int feature_col = 50;
float feature_threshold = 0.01;
string add_noise = "false";
string noise_correlated = "true";

foreach level, i in std_dev_array
{
    foreach trial, k in trials
    {
      std_dev = level * std_dev_step;
      run_id = "%0.2f-%01i" % (std_dev, k);
      params = ("{ \"label_noise\" : %f , "  +
		" \"max_abs\" : %f, "  +
		" \"noise_correlated\" : %s, "  +
		" \"feature_col\" : %i, "  +
		" \"feature_threshold\" : %f, "  +
                "  \"epochs\"        : 100  } ") %
                (std_dev, std_dev, noise_correlated, feature_col, feature_threshold);
      printf("running: %s", params);
      result = obj(params, run_id);
      printf("result %s : std_dev %0.2f : %s",
             run_id, std_dev, result);
    }
}
