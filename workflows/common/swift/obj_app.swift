
// OBJ APP

/**
    The main objective function used by the CANDLE/Supervisor
    model exploration (optimization) loop.
    params : The JSON string of params to be passed to the Benchmark
    run_id : A string run ID that will be the output directory name
*/
(string obj_result) obj(string params,
                        string run_id) {
  string model_sh       = getenv("MODEL_SH");
  string turbine_output = getenv("TURBINE_OUTPUT");

  string outdir = "%s/run/%s" % (turbine_output, run_id);
  // printf("running model shell script in: %s", outdir);
  // We do not use a file type here because this file may not be created,
  // which is handled by get_results()
  string result_file = outdir/"result.txt";
  wait (run_model(model_sh, params, run_id))
  {
    obj_result = get_results(result_file);
  }
  printf("result(%s): %s", run_id, obj_result);
}

/**
   Swift/T app function that runs the Benchmark
*/
app (void o) run_model (string model_sh, string params,
                        string runid)
{
  //                  1       2      3
  "bash" model_sh FRAMEWORK params runid;
}

/**
   Extracts the Benchmark output if it exists,
   else, provides a NaN so the workflow can keep running
*/
(string obj_result) get_results(string result_file) {
  if (file_exists(result_file)) {
    file line = input(result_file);
    obj_result = trim(read(line));
  } else {
    printf("File not found: %s", result_file);
    obj_result = "NaN";
  }
}
