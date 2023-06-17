/*
  DENSE NOISE WORKFLOW SWIFT
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

string turbine_output = getenv("TURBINE_OUTPUT");

string exp_id        = argv("exp_id");
string train_sources = argv("train");

string model_name = getenv("MODEL_NAME");

printf("DENSE NOISE WORKFLOW.SWIFT");
printf("TURBINE_OUTPUT: " + turbine_output);
printf("model_name: " + model_name);

int epochs = 10;

int neurons[] = [500:1000:50];

float y_num_noises = 10; // Number of noise levels to try
float y_noise_levels[] = [0:y_num_noises];
float noise_step = 5; // Difference between noises

int num_trials = 5;
int trials[] = [0:num_trials-1];

print("num_trials: %i", num_trials);

/*
 GDSC - big and slow
 gCSI - small
 CTRP - small
 ALMANAC -
 NCI60
*/
printf("train_sources: " + train_sources);

json_template = """
{
  "layer_force": %4i,
  "noise"      : %5.2f,
  "epochs"     : %2i,
  "train_sources" : "%s",
  "experiment_id": "%s",
  "run_id":        "%s",
  "candle_result": "val_loss",
  "ckpt_save_interval": 1
}
""";

foreach neuron in neurons
{
  foreach levely, j in y_noise_levels
  {
    foreach trial, k in trials
    {
      y_noise_level = levely * noise_step;
      run_id = "%04i-%06.2f-%02i" % (neuron, y_noise_level, trial);
      params = json_template %
        (neuron, y_noise_level, epochs, train_sources, exp_id, run_id);
      printf("running: %s: %s", run_id, params);
      result = candle_model_train(params, exp_id, run_id, model_name);
      printf("result: %s : neuron %i y_noise %0.3f : %s",
             run_id, neuron, y_noise_level, result);
    }
  }
}
