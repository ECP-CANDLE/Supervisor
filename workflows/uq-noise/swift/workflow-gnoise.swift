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

float std_dev_step = 0.025; // Difference between noises
int num_trials = 1;

float num_std_dev_noise= 20; // Number of noise levels to try

float std_dev_array[] = [0:num_std_dev_noise];
int trials[]       = [0:num_trials-1];

int feature_col = 50;
float feature_threshold = 0.02;
string add_noise = "false";
string gaussian_noise = "true";
string noise_correlated = "false";

foreach level, i in std_dev_array
{
    foreach trial, k in trials
    {
      std_dev = level * std_dev_step;
      run_id = "%0.3f-%01i" % (std_dev, k);
      params = ("{ \"std_dev\" : %f , "  +
		" \"add_noise\" : %s, "  +
		" \"gaussian_noise\" : %s, "  +
		" \"noise_correlated\" : %s, "  +
		" \"feature_threshold\" : %f, "  +
		" \"feature_col\" : %i, "  +
                "  \"epochs\"        : 200  } ") %
                (std_dev, add_noise, gaussian_noise, noise_correlated, feature_threshold, feature_col);
      printf("running: %s", params);
      result = obj(params, run_id);
      printf("result %s : std_dev %0.2f : %s",
             run_id, std_dev, result);
    }
}
