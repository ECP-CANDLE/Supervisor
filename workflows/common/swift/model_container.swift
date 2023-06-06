
/**
   CANDLE MODEL: CONTAINER
   Runs CANDLE models as Swift/T app functions
   under a Singularity container
*/

/**
    The main objective function used by the CANDLE/Supervisor
    model exploration (optimization) loop.
    params : The JSON string of params to be passed to the Benchmark
    run_id : A string run ID that will be the output directory name
    model_name : A path to a SIF
*/
(string model_result) candle_model_train(string params,
                                       string expid,
                                       string runid,
                                       string model_name)
{
  CDD      = getenv("CANDLE_DATA_DIR");
  model_sh = getenv("MODEL_SH");

  model_token = rootname_string(basename_string(model_name));
  outdir = "%s/%s/Output/%s/%s" % (CDD, model_token, expid, runid);
  printf("candle_model_train_container(): running in: %s", outdir);

  // We do not use a file type here because this file may not be created,
  // which is handled by get_results()
  result_file = outdir/"result.txt";
  wait (run_model_train(model_sh, params, expid, runid, model_name))
  {
    model_result = get_results(result_file);
  }
  printf("candle_model_train_container(): result(%s): '%s'",
         runid, model_result);
}

/**
   Swift/T app function that runs the Benchmark
*/
app (void o) run_model_train(string model_sh, string params,
                             string expid, string runid,
                             string model_name)
{
  //                  1       2      3     4         5           6          7
  "bash" model_sh FRAMEWORK params expid runid "SINGULARITY" model_name "train";
}

/**
   Extracts the model output if it exists,
   else, provides a NaN so the workflow can keep running
*/
(string model_result) get_results(string result_file) {
  if (file_exists(result_file)) {
    file line = input(result_file);
    model_result = trim(read(line));
  } else {
    printf("File not found: %s", result_file);
    model_result = "NaN";
  }
}
