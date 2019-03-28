
/*
  XCORR SWIFT
  Main cross-correlation workflow
*/

import files;
import io;
import python;
import unix;
import sys;
import string;
import EQR;
import location;
import math;

string FRAMEWORK = "keras";

string xcorr_root = getenv("XCORR_ROOT");
string preprocess_rnaseq = getenv("PREPROP_RNASEQ");
string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");
string model_sh       = getenv("MODEL_SH");

printf("TURBINE_OUTPUT: " + turbine_output);

string cache_dir = argv("cache_dir");
string xcorr_data_dir = argv("xcorr_data_dir");
string gpus = argv("gpus", "");

string exp_id = argv("exp_id");
int benchmark_timeout = toint(argv("benchmark_timeout", "-1"));

string site = argv("site");

/**
   Swift/T app function that runs the Benchmark
*/
app (void o) run_model (string model_sh, string instance_dir, string data_file, string model_file)
{
  //              1            2         3          
  "bash" model_sh instance_dir data_file model_file;
}


//python uno_infer.py --data CTRP_CCLE_2000_1000_test.h5 --model_file model.h5 --weights_file weights.h5

main() {
  //printf("hello");
  file f = input(argv("f"));
  //printf(argv("f"));
  string lines[] = file_lines(f);
  foreach params, i in lines {
    string instance = "%s/run/%i/" % (turbine_output, i);
    string ps[] = split(params, ",");
    string save_path = ps[1];
    file model[] = glob(save_path + "*.model.h5");
    //file weights[] = glob(save_path + "weights.h");
    string data_file = cache_dir + "/" + ps[0];
    run_model(model_sh, instance, data_file, filename(model[0]));
    //run_model(model_sh, instance, data_file, "foo.json", "foo.weights.h5");
  }
}

