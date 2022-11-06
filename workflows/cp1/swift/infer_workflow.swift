
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
import unix;

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
string n_pred = argv("n_pred");

/**
   Swift/T app function that runs the Benchmark
*/
app (void o) run_model (string model_sh, string instance_dir, string data_file, string model_file, string run_id)
{
  //              1            2         3          4      5
  "bash" model_sh instance_dir data_file model_file n_pred run_id;
}

write_lines(string lines[], string f) {
  string lines_string = join(lines,"\n");
  fname = "%s/%s" % (turbine_output, f);
  file out <fname> = write(lines_string);
}


//python uno_infer.py --data CTRP_CCLE_2000_1000_test.h5 --model_file model.h5 --weights_file weights.h5

main() {
  //printf("hello");
  file f = input(argv("f"));
  //printf(argv("f"));
  string lines[] = file_lines(f);
  string inputs[];
  foreach params, i in lines {
    string instance = "%s/run/%i/" % (turbine_output, i);
    string ps[] = split(params, ",");
    string save_path = ps[1];
    file model[] = glob(save_path + "*.model.h5");
    // file weights[] = glob(save_path + "weights.h");
    string data_file = cache_dir + "/" + ps[0];
    // model class|data file|model|instance_dir|n_pred
    inputs[i] = "%s|%s|%s|%s|%s" % (ps[2], data_file, filename(model[0]), instance, n_pred);
    run_model(model_sh, instance, data_file, filename(model[0]), int2string(i));
    printf("RUN MODEL: %s, %s, %s, %s, %s" % (model_sh, instance, data_file, filename(model[0]), n_pred));
    //run_model(model_sh, instance, data_file, "foo.json", "foo.weights.h5");
  }

  write_lines(inputs, "log.txt");
}
