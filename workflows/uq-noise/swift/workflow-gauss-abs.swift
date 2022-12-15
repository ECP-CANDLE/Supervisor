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
float feature_threshold = 0.01;
string add_noise = "false";
string noise_correlated = "false";
string gaussian_noise = "true";


float abs_vals[]  = [0.01964286183, 0.01785714711, 0.01785714711, 0.02500000596, 0.02500000596, 0.03035715009, 0.03392857526, 0.03392857526, 0.05892858122, 0.05714286438, 0.08928572493, 0.1000000047, 0.1053571467, 0.1821428537, 0.1732142823, 0.2124999974, 0.2339285719, 0.1982142861, 0.3696428559, 0.2250000026, 0.2999999991];

foreach level, i in std_dev_array
{
    foreach trial, k in trials
    {
      std_dev = level * std_dev_step;
      run_id = "%0.2f-%01i" % (std_dev, k);

      max_abs = abs_vals[i];

      params = ("{ \"label_noise\" : %f , "  +
                " \"max_abs\" : %f, "  +
                " \"std_dev\" : %f, "  +
                " \"gaussian_noise\" : %s, "  +
                " \"noise_correlated\" : %s, "  +
                " \"feature_col\" : %i, "  +
                " \"feature_threshold\" : %f, "  +
                "  \"epochs\"        : 100  } ") %
                (std_dev, max_abs, std_dev, gaussian_noise, noise_correlated, feature_col, feature_threshold);
      printf("running: %s", params);
      result = obj(params, run_id);
      printf("result %s : std_dev %0.2f : %s",
             run_id, std_dev, result);
    }
}
