import io;
import sys;
import files;
import location;
import string;
import EQPy;
import python;


string emews_root = getenv("EMEWS_PROJECT_ROOT");
string turbine_output = getenv("TURBINE_OUTPUT");

string resident_work_ranks = getenv("RESIDENT_WORK_RANKS");
string r_ranks[] = split(resident_work_ranks,",");

int ME1_RANK_IDX = 0;
int CACHE_RANK_IDX = 1;

// (string cls) run_model(string params, int iter, int p_num) {

//     string results[];
//     // i is used as random seed in input xml
//     foreach i in [0:trials-1:1] {
//       string instance = "%s/instance_%i_%i_%i/" % (turbine_output, iter, p_num, i+1);
//       make_dir(instance) => {
//         xml_out = instance + "config.xml";
//         //printf("params: %s", params);
//         code = to_xml_code % (params, num_threads, i, tisd, default_xml_config, xml_out);
//         file out <instance+"out.txt">;
//         file err <instance+"err.txt">;
//         python_persist(code, "'ignore'") =>
//         (out,err) = run(model_sh, xml_out, instance) =>
//         results[i] = parse_tumor_cell_count(instance);
//       }
//     }

//     string result = string_join(results, ",");
//     string code = result_template % result;
//     cls = R(code, "toString(res)");
// }

() print_time (string id) "turbine" "0.0" [
  "puts [concat \"@\" <<id>> \" time is: \" [clock milliseconds]]"
];


(string r) get_result() {
  r = "(3,10)";
}

(string result) start_me2(string params, int iter, int param_id, string me2_rank) {
    location me2_location = locationFromRank(string2int(me2_rank));
    //printf(me2_rank);
    EQPy_run(me2_location) =>
    EQPy_put(me2_location, me2_rank) =>
    EQPy_put(me2_location, params) =>
    run_me2(me2_location, iter, param_id, me2_rank) => 
    // get fake results from ME2 run
    result = get_result();
}

(string result) run_model(string params, int me2_iter, int param_id) {
  result = params;
}

(void v) run_me2(location loc, int sample_iter, int param_id, string me2_rank) {

    for (boolean b = true, int i = 1;
       b;
       b=c, i = i + 1)
  {
    string params =  EQPy_get(loc);
    //printf("Iter %i  next params: %s", i, params);
    //printf("ME2 Iter %i, %i, %i", sample_iter, param_id, i);
    //printf("ME Params: %s", params);
    boolean c;
    if (params == "DONE") {
        string final_results = EQPy_get(loc) =>
        //printf("ME2 final results: %s", final_results);
        v = make_void() =>
        c = false;
    } else if (params == "EQPy_ABORT") {
      printf("EQPy ME2 aborted: see output for Python error") =>
      string why = EQPy_get(loc);
      printf("%s", why) =>
      v = propagate() =>
      c = false;
    } else {
      string param_array[] = split(params, ";");
      string results[];
      foreach p, j in param_array
      {
          // TODO update run_model with code to actually
          // run the model with the parameters 
          // produced from the active learning.
          results[j] = run_model(p, i, j);
      }

      string res = join(results, ";");
      EQPy_put(loc, res) => c = true;
    }
  }
}

(void o) init_tasks_cache() {
  rank = r_ranks[CACHE_RANK_IDX];
  location loc = locationFromRank(string2int(rank));
  EQPy_init_package(loc, "task_cache") => 
  EQPy_run(loc) =>
  EQPy_put(loc, join(r_ranks, ",")) =>
  o = propagate();
}

(void o) init_me2_rank(string rank) {
  location loc = locationFromRank(string2int(rank));
  EQPy_init_package(loc, "me2") =>
  EQPy_put(loc, join(r_ranks, ",")) =>
  o = propagate();
}

(string waiter[]) init_me2_ranks() {
  foreach i in [2 : size(r_ranks) - 1] {
    init_me2_rank(r_ranks[i]);
    waiter[i] = r_ranks[i];
  } 
}

(void o) start() {
    rank = r_ranks[ME1_RANK_IDX];
    location loc = locationFromRank(string2int(rank));
    location cache_loc = locationFromRank(string2int(r_ranks[CACHE_RANK_IDX]));
    string me1_params = "";
    EQPy_init_package(loc, "me1") =>
    EQPy_run(loc) =>
    EQPy_put(loc, me1_params) =>
    run_workflow(loc, cache_loc) => {
        EQPy_put(cache_loc, "DONE") =>
        EQPy_stop(loc);
        EQPy_stop(cache_loc);
        o = propagate();
    }
}

(void o) run() {
    init_tasks_cache() =>
    init_me2_ranks() =>
    start() =>
    o = propagate();
}

(void v) run_workflow(location sample_loc, location cache_loc) {

    for (boolean b = true, int i = 1;
       b;
       b=c, i = i + 1)
  {
    string params =  EQPy_get(sample_loc);
    //printf("Iter %i  next params: %s", i, params);
    printf("Sample Iter %i", i);
    boolean c;
    if (params == "DONE") {
        string final_results =  EQPy_get(sample_loc);
        printf(final_results);
        v = make_void() =>
        c = false;
    } else if (params == "EQPy_ABORT") {
      printf("EQPy aborted: see output for Python error") =>
      string why = EQPy_get(sample_loc);
      printf("%s", why) =>
      v = propagate() =>
      c = false;
    } else {
      string param_array[] = split(params, ";");
      string results[];
      // printf("%i", size(param_array));
      // Lauch an me2 run for each set of parameters produced by 
      // me1
      foreach p, j in param_array
      {
          string free_rank = EQPy_get(cache_loc);
          results[j] = start_me2(p, i, j, free_rank);
          //printf(results[j]);
      }

      string res = join(results, ";");
      EQPy_put(sample_loc, res) => c = true;
    }
  }
}

run();
