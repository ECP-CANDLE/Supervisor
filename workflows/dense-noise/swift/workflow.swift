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

int epochs = 1;

int neurons[] = [500:1000:250];

float y_num_noises = 1; // Number of noise levels to try
float y_noise_levels[] = [0:y_num_noises];
float noise_step = 10; // Difference between noises

int num_trials = 1;
int trials[] = [0:num_trials-1];

foreach neuron in neurons
{
  foreach levely, j in y_noise_levels
  {
    foreach trial, k in trials
    {
      y_noise_level = levely * noise_step;
      run_id = "%04i-%0.0f-%02i" % (neuron, y_noise_level, trial);
      params = ("{ \"layer_force\" : %i , "  +
                "  \"noise\" : %f , "  +
                "  \"epochs\"        :  %i } ") %
                (neuron, y_noise_level, epochs);
      printf("running: %s", params);
      result = obj(params, exp_id, run_id);
      printf("result %s : neuron %i y_noise %0.3f : %s",
             run_id, neuron, y_noise_level, result);
    }
  }
}
