import io;
import sys;
import files;
import location;
import string;
import EQR;
import R;
import assert;
import python;

string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");
string resident_work_ranks = getenv("RESIDENT_WORK_RANKS");
string r_ranks[] = split(resident_work_ranks,",");
int propose_points = toint(argv("pp", "3"));
int max_budget = toint(argv("mb", "110"));
int max_iterations = toint(argv("it", "5"));
int design_size = toint(argv("ds", "10"));
string param_set = argv("param_set_file");
string model_name = argv("model_name");
file model_script = input(argv("script_file"));
file log_script = input(argv("log_script"));
string exp_id = argv("exp_id");
int benchmark_timeout = toint(argv("benchmark_timeout", "-1"));
string site = argv("site");

string FRAMEWORK = "keras";

(void o) log_start(string algorithm) {
    file out <"%s/log_start_out.txt" % turbine_output>;
    file err <"%s/log_start_err.txt" % turbine_output>;

    string ps = join(file_lines(input(param_set)), " ");
    string t_log = "%s/turbine.log" % turbine_output;
    if (file_exists(t_log)) {
      string sys_env = join(file_lines(input(t_log)), ", ");
      (out, err) = run_log_start(log_script, ps, sys_env, algorithm, site) =>
      o = propagate();
    } else {
      (out, err) = run_log_start(log_script, ps, "", algorithm, site) =>
      o = propagate();
    }
}

(void o) log_end() {
  file out <"%s/log_end_out.txt" % turbine_output>;
  file err <"%s/log_end_err.txt" % turbine_output>;
  (out, err) = run_log_end(log_script, site) =>
  o = propagate();
}

(void v) loop(location ME, int ME_rank) {

    for (boolean b = true, int i = 1;
       b;
       b=c, i = i + 1)
  {
    string params =  EQR_get(ME);
    boolean c;

    if (params == "DONE")
    {
      string finals =  EQR_get(ME);
      // TODO if appropriate
      // split finals string and join with "\\n"
      // e.g. finals is a ";" separated string and we want each
      // element on its own line:
      // multi_line_finals = join(split(finals, ";"), "\\n");
      string fname = "%s/final_res.Rds" % (turbine_output);
      printf("See results in %s", fname) =>
      // printf("Results: %s", finals) =>
      v = make_void() =>
      c = false;
    }
    else if (params == "EQR_ABORT")
    {
      printf("EQR aborted: see output for R error") =>
      string why = EQR_get(ME);
      printf("%s", why) =>
      v = propagate() =>
      c = false;
    }
    else
    {

        string param_array[] = split(params, ";");
        string results[];
        foreach p, j in param_array
        {
          // printf(p);
            results[j] = obj(p, "%i_%i_%i" % (ME_rank,i,j), site);
        }
        string res = join(results, ";");
        // printf(res);
        EQR_put(ME, res) => c = true;
    }
  }
}

string algo_params_template =
"""
max.budget = %d, max.iterations = %d, design.size=%d, propose.points=%d, param.set.file='%s'
""";

(void o) start(int ME_rank) {
    location ME = locationFromRank(ME_rank);
    // TODO: Edit algo_params to include those required by the R
    // algorithm.
    // algo_params are the parameters used to initialize the
    // R algorithm. We pass these as a comma separated string.
    // By default we are passing a random seed. String parameters
    // should be passed with a \"%s\" format string.
    // e.g. algo_params = "%d,%\"%s\"" % (random_seed, "ABC");
    // Retrieve arguments to this script here

    string algo_params = algo_params_template %
      (max_budget, max_iterations, design_size, propose_points, param_set);
    string algorithm = strcat(emews_root,"/R/mlrMBO3.R");
    log_start(algorithm) =>
    EQR_init_script(ME, algorithm) =>
    EQR_get(ME) =>
    EQR_put(ME, algo_params) =>
    loop(ME, ME_rank) => {
        EQR_stop(ME) =>
        log_end() =>
        EQR_delete_R(ME);
        o = propagate();
    }
}

main() {

  assert(strlen(emews_root) > 0, "Set EMEWS_PROJECT_ROOT!");

  int ME_ranks[];
  foreach r_rank, i in r_ranks{
    ME_ranks[i] = toint(r_rank);
  }

  foreach ME_rank, i in ME_ranks {
    start(ME_rank) =>
    printf("End rank: %d", ME_rank);
  }
}
