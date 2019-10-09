
// OBJ ECHO

/**
    This has the same signature as the main objective function
    used by the CANDLE/Supervisor;
    except it just echoes the resulting command to stdout
    params : The JSON string of params to be passed to the Benchmark
    run_id : A string run ID that will be the output directory name
*/
(string obj_result) obj(string params_in,
                        string run_id) {
  string model_sh       = getenv("MODEL_SH");
  string turbine_output = getenv("TURBINE_OUTPUT");

  string outdir = "%s/run/%s" % (turbine_output, run_id);
  params = replace_all(params_in, "\n", "", 0);
  //                                              1       2       3
  printf("bash model.sh %s %s %s in: %s", FRAMEWORK, params, run_id,
         turbine_output) =>
    obj_result = "ECHO SUCCESS";
}
