# Run mlrMBO based hyperparameter optimization on CANDLE Benchmarks

mlrMBO is an iterative optimizer written in R. It evaluates the best values of hyperparameters for CANDLE "Benchmarks" available here: `git@github.com:ECP-CANDLE/Benchmarks.git` - given set of parameters.

## Running ##

1. cd into the *~/Supervisor/workflows/mlrMBO/test* directory
2. Specify the MODEL_NAME in *test-1.sh* file, hyperparameters in *cfg-prm-1.txt*
3. Specify the #procs, queue etc. in *cfg-sys-1.sh* file
4. Launch the test by invoking *./upf-1.sh <machine_name>*
    where machine_name can be cori, theta, titan etc.
5. The benchmark will be run for the number of processors specified
6. Final objective function value will be available in the experiments directory and also printed


## User requirements ##

What you need to install to run the workflow:

* This workflow - `git@github.com:ECP-CANDLE/Supervisor.git` .
  Clone and `cd` to `workflows/nt3_mlrMBO`
  (the directory containing this README).
* NT3 benchmark - `git@github.com:ECP-CANDLE/Benchmarks.git` .
  Clone and switch to the `frameworks` branch.
* benchmark data -
 See the individual benchmarks README for obtaining the initial data

## Calling sequence ##

Function calls :-
* test-1.sh -> swift/workflow.sh -> swift/workflow.swift ->
common/swift/obj_app.swift -> common/sh/model.sh ->
common/python/model_runner.py -> 'calls the benchmark'

Scheduling scripts :-
* upf-1.sh -> cfg-sys-1.sh -> common/sh/<machine_name> - module, scheduling, langs .sh files