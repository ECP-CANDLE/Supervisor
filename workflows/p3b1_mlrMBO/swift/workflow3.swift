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
int propose_points = toint(argv("pp", "10"));
int max_budget = toint(argv("mb", "110"));
int max_iterations = toint(argv("mi", "10"));
int design_size = toint(argv("ds", "10"));
string param_set = argv("param_set_file");
string exp_id = argv("exp_id");
int benchmark_timeout = toint(argv("benchmark_timeout", "-1"));

string code_template =
"""
import p3b1_runner
import json, os

outdir = '%s'

if not os.path.exists(outdir):
    os.makedirs(outdir)

hyper_parameter_map = json.loads('%s')
hyper_parameter_map['framework'] = 'keras'
hyper_parameter_map['save'] = '{}/output'.format(outdir)
hyper_parameter_map['instance_directory'] = outdir
hyper_parameter_map['experiment_id'] = '%s'
hyper_parameter_map['run_id'] = '%s'
hyper_parameter_map['timeout'] = %d

validation_loss = p3b1_runner.run(hyper_parameter_map)
""";

string code_log_start =
"""
import exp_logger

parameter_map = {}
parameter_map['pp'] = '%d'
parameter_map['iterations'] = '%d'
parameter_map['params'] = \"\"\"%s\"\"\"
parameter_map['algorithm'] = '%s'
parameter_map['experiment_id'] = '%s'
sys_env = \"\"\"%s\"\"\"

exp_logger.start(parameter_map, sys_env)
""";

string code_log_end =
"""
import exp_logger

exp_logger.end('%s')
""";

// algorithm params format is a string representation
// of a python dictionary. eqpy_hyperopt evals this
// string to create the dictionary. This, unfortunately,
string algo_params_template =
"""
max.budget = %d, max.iterations = %d, design.size=%d, propose.points=%d, param.set.file='%s'
""";

(string obj_result) obj(string params, string iter_indiv_id) {
  string outdir = "%s/run_%s" % (turbine_output, iter_indiv_id);
  string code = code_template % (outdir, params, exp_id, iter_indiv_id, benchmark_timeout);
  //make_dir(outdir) =>
  obj_result = python_persist(code, "str(validation_loss)");
  printf(obj_result);
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
            printf(p);
            results[j] = obj(p, "%i_%i_%i" % (ME_rank,i,j));
        }
        string res = join(results, ";");
        printf(res);
        EQR_put(ME, res) => c = true;
    }
  }
}

(void o) log_start(string algorithm) {
    string ps = join(file_lines(input(param_set)), " ");
    string sys_env = join(file_lines(input("%s/turbine.log" % turbine_output)), ", ");
    string code = code_log_start % (propose_points, max_iterations, ps, algorithm, exp_id, sys_env);
    python_persist(code);
    o = propagate();
}

(void o) log_end(){
    string code = code_log_end % (exp_id);
    python_persist(code);
    o = propagate();
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

    string algo_params = algo_params_template % (max_budget, max_iterations,
  design_size, propose_points, param_set);
    string algorithm = strcat(emews_root,"/R/mlrMBO3.R");
    log_start(algorithm);
    EQR_init_script(ME, algorithm) =>
    EQR_get(ME) =>
    EQR_put(ME, algo_params) =>
    loop(ME, ME_rank) => {
        EQR_stop(ME) =>
        EQR_delete_R(ME);
        log_end() =>
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
