
// OBJ APP

// (string obj_result) obj(string params, string iter_indiv_id) {
//   string outdir = "%s/run_%s" % (turbine_output, iter_indiv_id) =>
//   run_model(model_script, params, outdir, iter_indiv_id) =>
//   string result_file = "%s/result.txt" % outdir =>
//   obj_result = get_results(result_file);
//   printf(obj_result);
// }

(string obj_result) obj(string params, string iter_indiv_id, string site) {
  string outdir = "%s/run_%s" % (turbine_output, iter_indiv_id);
  printf("run model: %s", outdir);
  string result_file = outdir/"result.txt";
  wait (run_model(model_script, params, outdir, iter_indiv_id, site))
  {
    obj_result = get_results(result_file);
  }
  printf("result(%s): %s", iter_indiv_id, obj_result);
}

app (void o) run_model (file shfile, string params_string, string instance, string run_id, string site)
{
    "bash" shfile params_string emews_root instance model_name FRAMEWORK exp_id run_id benchmark_timeout site;
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
