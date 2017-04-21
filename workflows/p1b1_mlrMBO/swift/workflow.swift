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
string data_dir = argv("data_directory");
int propose_points = toint(argv("pp", "3"));
int max_iterations = toint(argv("it", "5"));
string param_set = argv("param_set_file");

string p1b1_template =
"""
import p1b1_runner

# args: p1b1 data directory, parameter string
a = p1b1_runner.run('%s', '%s')
""";

// algorithm params format is a string representation
// of a python dictionary. eqpy_hyperopt evals this
// string to create the dictionary. This, unfortunately,
string algo_params_template =
"""
pp = %d, it = %d, param.set.file='%s'
""";

(string obj_result) obj(string params, string iter_indiv_id) {
  // Typical code might create multiple sets of parameters from a single
  // set by duplicating that set some number of times and appending a
  // different random seed to each of the new sets. The example doesn't
  // do that so we only need to run obj rather than create those new
  // parameters and iterate over them.
  // string parameter_combos[] = create_parameter_combinations(params, trials);
  // float fresults[];
  //foreach f,i in params {
  //    string id_suffix = "%s_%i" % (iter_indiv_id,i);
  //    fresults[i] = run_obj(f, id_suffix);
  //}
  // not using unique id suffix but we could use it to create
  // a per run unique directory if we need such
  string id_suffix = "%s_%i" % (iter_indiv_id,1);
  string p1b1_code = p1b1_template % (data_dir, params);
  //printf(p1b1_code);
  obj_result = python_persist(p1b1_code, "str(a)");
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
            results[j] = obj(p, "%i_%i_%i" % (ME_rank,i,j));
        }
        string res = join(results, ";");
        EQR_put(ME, res) => c = true;
    }
  }
}

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

    string algo_params = algo_params_template % (propose_points,
      max_iterations, param_set);
    string algorithm = strcat(emews_root,"/R/mlrMBO.R");
    EQR_init_script(ME, algorithm) =>
    EQR_get(ME) =>
    EQR_put(ME, algo_params) =>
    loop(ME, ME_rank) => {
        EQR_stop(ME) =>
        EQR_delete_R(ME);
        o = propagate();
    }
}

// deletes the specified directory
app (void o) rm_dir(string dirname) {
  "rm" "-rf" dirname;
}

// call this to create any required directories
app (void o) make_dir(string dirname) {
  "mkdir" "-p" dirname;
}

// anything that need to be done prior to a model runs
// (e.g. file creation) can be done here
//app (void o) run_prerequisites() {
//
//}

main() {

  assert(strlen(emews_root) > 0, "Set EMEWS_PROJECT_ROOT!");

  int ME_ranks[];
  foreach r_rank, i in r_ranks{
    ME_ranks[i] = toint(r_rank);
  }

  //run_prerequisites() => {
  foreach ME_rank, i in ME_ranks {
    start(ME_rank) =>
    printf("End rank: %d", ME_rank);
  }
//}
}
