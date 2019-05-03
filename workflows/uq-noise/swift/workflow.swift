
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

printf("UQ NOISE WORKFLOW.SWIFT");
printf("TURBINE_OUTPUT: " + turbine_output);

string db_file = argv("db_file");
string cache_dir = argv("cache_dir");
string xcorr_data_dir = argv("xcorr_data_dir");
string gpus = argv("gpus", "");

// string restart_number = argv("restart_number", "1");
string site = argv("site");

float noise_step = 3.0; // Difference between noises
float num_noises = 3; // Number of noise levels to try
int num_trials = 3;

float noise_levels[] = [0:num_noises];
int trials[]       = [0:num_trials];

string results[][];

app (file o) nt3(int trial, float noise)
{
  (emews_root/"swift/fake-nt3.sh") trial noise o ;
}

foreach noise_level, i in noise_levels
{
  foreach trial, j in trials
  {
    float noise = 0.01 * noise_step * noise_level;
    dir = "run/%i-%0.3f"%(trial, noise);
    mkdir(dir) =>
      fname = dir/"result.txt";
    file f<fname> = nt3(trial, noise);
    results[i][j] = read(f);
  }
}
