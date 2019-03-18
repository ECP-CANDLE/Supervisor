
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
string exp_id = argv("exp_id");
int benchmark_timeout = toint(argv("benchmark_timeout", "-1"));
string restart_file = argv("restart_file", "DISABLED");
string r_file = argv("r_file", "mlrMBO1.R");

printf("CANDLE mlrMBO Workflow");
printf("TURBINE_OUTPUT: " + turbine_output);

string restart_number = argv("restart_number", "1");
string site = argv("site");

if (restart_file != "DISABLED") {
  assert(restart_number != "1",
         "If you are restarting, you must increment restart_number!");
}

string FRAMEWORK = "keras";

(void v) loop(location ME) {

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
      v = propagate(finals) =>
      c = false;
    }
    else if (params == "EQR_ABORT")
    {
      printf("EQR aborted: see output for R error") =>
      string why = EQR_get(ME);
      printf("%s", why) =>
          // v = propagate(why) =>
      c = false;
    }
    else
    {
        string param_array[] = split(params, ";");
        string results[];
        foreach param, j in param_array
        {
            results[j] = obj(param,
                             "%00i_%000i_%0000i" % (restart_number,i,j));
        }
        string result = join(results, ";");
        // printf(result);
        EQR_put(ME, result) => c = true;
    }
  }
}

// These must agree with the arguments to the objective function in mlrMBO.R,
// except param.set.file is removed and processed by the mlrMBO.R algorithm wrapper.
string algo_params_template =
"""
param.set.file='%s',
max.budget = %d,
max.iterations = %d,
design.size=%d,
propose.points=%d,
restart.file = '%s'
""";

(void o) start(int ME_rank) {
    location ME = locationFromRank(ME_rank);

    // algo_params is the string of parameters used to initialize the
    // R algorithm. We pass these as R code: a comma separated string
    // of variable=value assignments.
    string algo_params = algo_params_template %
        (param_set, max_budget, max_iterations, design_size,
         propose_points, restart_file);
    string algorithm = emews_root+"/../common/R/"+r_file;
    EQR_init_script(ME, algorithm) =>
    EQR_get(ME) =>
    EQR_put(ME, algo_params) =>
    loop(ME) => {
        EQR_stop(ME) =>
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

// Local Variables:
// c-basic-offset: 4
// End:
