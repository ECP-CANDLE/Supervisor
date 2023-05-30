
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
import assert;
import python;

import candle_utils;
report_env();

string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");
string resident_work_ranks = getenv("RESIDENT_WORK_RANKS");
string r_ranks[] = split(resident_work_ranks,",");

string strategy = argv("strategy");
string ga_params_file = argv("ga_params");
// string init_params_file = argv("init_params", "");
float mut_prob = string2float(argv("mutation_prob", "0.2"));

string exp_id = argv("exp_id");
int benchmark_timeout = toint(argv("benchmark_timeout", "-1"));
string model_name     = getenv("MODEL_NAME");
string candle_model_type     = getenv("CANDLE_MODEL_TYPE");
string candle_image     = getenv("CANDLE_IMAGE");
string init_params_file     = getenv("INIT_PARAMS_FILE");

printf("TURBINE_OUTPUT: " + turbine_output);

string restart_number = argv("restart_number", "1");
string site = argv("site");

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
        foreach param, j in param_array
        {
            results[j] = candle_model_train(param, exp_id, "%00i_%000i_%0000i" % (restart_number,i,j), model_name);
        }
        string res = join(results, ";");
        // printf(res);
        EQPy_put(ME, res) => c = true;
    }
  }
}

(void o) start (int ME_rank, int iters, int pop, int seed) {
  location ME = locationFromRank(ME_rank);
  // (num_iter, num_pop, seed, strategy, mut_prob, ga_params_file)
  algo_params = "%d,%d,%d,'%s',%f, '%s', '%s'" %
    (iters, pop, seed, strategy, mut_prob, ga_params_file, init_params_file);
    EQPy_init_package(ME, "deap_ga") =>
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
  int num_pop = toint(argv("np","100")); // -np=100;

  //printf("NI: %i # num_iter", num_iter);
  //printf("NV: %i # num_variations", num_variations);
  //printf("NP: %i # num_pop", num_pop);
  //printf("MUTPB: %f # mut_prob", mut_prob);

  int ME_ranks[];
  foreach r_rank, i in r_ranks{
    ME_ranks[i] = toint(r_rank);
  }

  foreach ME_rank, i in ME_ranks {
    start(ME_rank, num_iter, num_pop, random_seed) =>
    printf("End rank: %d", ME_rank);
  }
}

// Local Variables:
// c-basic-offset: 4
// End:
