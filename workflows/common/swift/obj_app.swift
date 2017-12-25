
// OBJ APP

// (string obj_result) obj(string params, string iter_indiv_id) {
//   string outdir = "%s/run_%s" % (turbine_output, iter_indiv_id) =>
//   run_model(model_script, params, outdir, iter_indiv_id) =>
//   string result_file = "%s/result.txt" % outdir =>
//   obj_result = get_results(result_file);
//   printf(obj_result);
// }

(string obj_result) obj(string params, string iter_indiv_id, string obj_param) {
  string model_sh       = getenv("MODEL_SH");
  string turbine_output = getenv("TURBINE_OUTPUT");

  string outdir = "%s/run/%s" % (turbine_output, iter_indiv_id);
  // printf("running model shell script in: %s", outdir);
  string result_file = outdir/"result.txt";
  wait (run_model(model_sh, params, iter_indiv_id, obj_param))
  {
    obj_result = get_results(result_file);
  }
  printf("result(%s): %s", iter_indiv_id, obj_result);
}

app (void o) run_model (string model_sh, string params,
                        string runid, string obj_param)
{
  //                      1       2       3        4 
      "bash" model_sh FRAMEWORK params   runid  obj_param;
}

(string obj_result) get_results(string result_file) {
  if (file_exists(result_file)) {
    file line = input(result_file);
    obj_result = trim(read(line));
  } else {
    printf("File not found: %s", result_file);
    obj_result = "NaN";
  }
}
