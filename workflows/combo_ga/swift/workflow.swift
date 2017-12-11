
/*
 * WORKFLOW.SWIFT
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

string strategy = argv("strategy");
string ga_params_file = argv("ga_params");
float mut_prob = string2float(argv("mutation_prob", "0.2"));

string model_name = argv("model_name");
string model_sh = argv("model_sh");
string exp_id = argv("exp_id");
int benchmark_timeout = toint(argv("benchmark_timeout", "-1"));
string obj_param = argv("obj_param", "val_loss");

printf("turbine_output: " + turbine_output);
string site = argv("site");

printf("model_sh: %s", model_sh);

string restart_number = argv("restart_number", "1");

//string restart_file = argv("restart_file", "DISABLED");
//if (restart_file != "DISABLED") {
//  assert(restart_number != "1",
//         "If you are restarting, you must increment restart_number!");
//}

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
      string fname = "%s/final_result_%i" % (turbine_output, ME_rank);
      file results_file <fname> = write(finals) =>
      printf("Writing final result to %s", fname) =>
      // printf("Results: %s", finals) =>
      v = make_void() =>
      c = false;
    }
    else if (params == "EQPY_ABORT")
    {
        printf("EQPy Aborted");
        string why = EQPy_get(ME);
        // TODO handle the abort if necessary
        // e.g. write intermediate results ...
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
            results[j] = obj(p, "%00i_%000i_%0000i" % (restart_number,i,j), site, obj_param);
        }
        string res = join(results, ";");
        // printf(res);
        EQPy_put(ME, res) => c = true;
    }
  }
}

(void o) start (int ME_rank, int iters, int pop, int trials, int seed) {
  location ME = locationFromRank(ME_rank);
  // (num_iter, num_pop, seed, strategy, mut_prob, ga_params_file)
  algo_params = "%d,%d,%d,'%s',%f, '%s'" %
    (iters, pop, seed, strategy, mut_prob, ga_params_file);
    EQPy_init_package(ME,"deap_ga") =>
    EQPy_get(ME) =>
    EQPy_put(ME, algo_params) =>
      loop(ME, ME_rank) => {
        EQPy_stop(ME);
        o = propagate();
    }
}

main() {

  assert(strlen(emews_root) > 0, "Set EMEWS_PROJECT_ROOT!");

  int random_seed = toint(argv("seed", "0"));
  int num_iter = toint(argv("ni","100")); // -ni=100
  int num_variations = toint(argv("nv", "5"));
  int num_pop = toint(argv("np","100")); // -np=100;

  printf("NI: %i # num_iter", num_iter);
  printf("NV: %i # num_variations", num_variations);
  printf("NP: %i # num_pop", num_pop);
  printf("MUTPB: %f # mut_prob", mut_prob);

  int ME_ranks[];
  foreach r_rank, i in r_ranks{
    ME_ranks[i] = toint(r_rank);
  }

  foreach ME_rank, i in ME_ranks {
    start(ME_rank, num_iter, num_pop, num_variations, random_seed) =>
    printf("End rank: %d", ME_rank);
  }
}

// Local Variables:
// c-basic-offset: 4
// End:
