
/**
   CANDLE MODEL: CONTAINER
   Pretends to run CANDLE models, actually just echoes its arguments
*/

/**
    This has the same signature as the main objective function
    used by the CANDLE/Supervisor;
    except it just echoes the resulting command to stdout
    params : The JSON string of params to be passed to the Benchmark
    run_id : A string run ID that will be the output directory name
*/
(string model_result) candle_model_train(string params,
                                         string expid,
                                         string runid,
                                         string model_name)
{
  string model_sh       = getenv("MODEL_SH");
  string turbine_output = getenv("TURBINE_OUTPUT");

  string outdir = "%s/run/%s" % (turbine_output, run_id);
  params = replace_all(params_in, "\n", "", 0);
  //                                              1       2       3
  printf("bash model.sh %s %s %s in: %s", FRAMEWORK, params, run_id,
         turbine_output) =>
    model_result = "ECHO SUCCESS";
}
