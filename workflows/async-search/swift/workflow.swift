
/*
 * WORKFLOW.SWIFT
 * for CANDLE Benchmarks - mlrMBO
 */

import io;
import sys;
import files;
import location;
import string;
import unix;
import EQPy;
import R;
import assert;
import python;

string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");
string resident_work_ranks = getenv("RESIDENT_WORK_RANKS");
string r_ranks[] = split(resident_work_ranks,",");

int init_size = toint(argv("init_size", "4"));
int max_evals = toint(argv("max_evals", "20"));
int num_buffer = toint(argv("num_buffer", "2"));
int num_regular_workers = turbine_workers()-1;
int random_seed = toint(argv("seed", "0"));

string model_name = argv("model_name");
string exp_id = argv("exp_id");
int benchmark_timeout = toint(argv("benchmark_timeout", "-1"));
string restart_file = argv("restart_file", "DISABLED");
string py_package = argv("py_package", "async-search");

printf("TURBINE_OUTPUT: " + turbine_output);

string restart_number = argv("restart_number", "1");
string site = argv("site");

if (restart_file != "DISABLED") {
  assert(restart_number != "1",
         "If you are restarting, you must increment restart_number!");
}

string FRAMEWORK = "keras";

(void v) loop(location ME, int ME_rank) {

  for (boolean b = true, int i = 1;
       b;
       b=c, i = i + 1)
  {
    string params =  EQPy_get(ME);
    boolean c;

    if (params == "DONE")
    {
      string finals =  EQPy_get(ME);
      // TODO if appropriate
      // split finals string and join with "\\n"
      // e.g. finals is a ";" separated string and we want each
      // element on its own line:
      // multi_line_finals = join(split(finals, ";"), "\\n");
      //string fname = "%s/final_res.Rds" % (turbine_output);
      //printf("See results in %s", fname) =>
      string fname = "%s/final_result_%i" % (turbine_output, ME_rank);
      file results_file <fname> = write(finals) =>
      printf("Writing final result to %s", fname) =>
      //printf("Results: %s", finals) =>
      v = propagate(finals) =>
      c = false;
    }
    else if (params == "EQPY_ABORT")
    {
      printf("EQPy aborted: see output for Python error") =>
      string why = EQPy_get(ME);
      printf("%s", why) =>
          // v = propagate(why) =>
      c = false;
    }
    else
    {
        string param_array[] = split(params, ";") => c = true;
        foreach param, j in param_array
        {
            obj(param,"%00i_%000i_%0000i" % (restart_number,i,j), ME_rank);
        }
    }
  }
}


(void o) start(int ME_rank) {
    location ME = locationFromRank(ME_rank);

    // algo_params is the string of parameters used to initialize the
    // Python algorithm. We pass these as Python code: a comma separated string
    // of variable=value assignments.
    string algo_params = "%d,%d,%d,%d,%d" % (init_size, max_evals, num_regular_workers, num_buffer, random_seed);
    string algorithm = py_package;
    EQPy_init_package(ME, algorithm) =>
    EQPy_get(ME) =>
    EQPy_put(ME, algo_params) =>
    loop(ME, ME_rank) => {
        EQPy_stop(ME);
        o = propagate();
    }
}

main() {

  assert(strlen(emews_root) > 0, "Set EMEWS_PROJECT_ROOT!");

  int ME_ranks[];
  foreach r_rank, i in r_ranks{
    ME_ranks[i] = toint(r_rank);
  }
/*
  int num_r_ranks = size(r_ranks);
  int num_servers = adlb_servers();
  printf("num_r_ranks: " + num_r_ranks);
  printf("num_servers: " + num_servers);
*/
  foreach ME_rank, i in ME_ranks {
    start(ME_rank) =>
    printf("End rank: %d", ME_rank);
  }
}

// Local Variables:
// c-basic-offset: 4
// End:
