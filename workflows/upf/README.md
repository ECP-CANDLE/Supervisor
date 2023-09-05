# Evaluate an Unrolled Parameter File (UPF)

This workflow evaluates ensembles of "Benchmark" available here: `git@github.com:ECP-CANDLE/Benchmarks.git` for a given set of parameters.

## Running

1. cd into the _~/Supervisor/workflows/upf/test_ directory
2. Specify the MODEL*NAME in \_upf-1.sh* file, hyperparameters in _upf-1.txt_
3. Specify the #procs, queue etc. in _cfg-sys-1.sh_ file
4. Launch the test by invoking _./upf-1.sh <machine_name>_
   where machine_name can be cori, theta, titan etc.
5. The benchmark will be run for the number of processors specified
6. Final objective function value will be available in the experiments directory and also printed

## User requirements

What you need to install to run the workflow:

- This workflow - `git@github.com:ECP-CANDLE/Supervisor.git` .
  Clone and `cd` to `workflows/nt3_mlrMBO`
  (the directory containing this README).
- NT3 benchmark - `git@github.com:ECP-CANDLE/Benchmarks.git` .
  Clone and switch to the `frameworks` branch.
- benchmark data -
  See the individual benchmarks README for obtaining the initial data
- Swift/T with the recently implemented JSON module,
  cf. https://github.com/swift-lang/swift-t/issues/121

## Calling sequence

Script call stack :-

- upf-1.sh -> swift/workflow.sh -> swift/workflow.swift ->
  common/swift/obj_app.swift -> common/sh/model.sh ->
  common/python/model_runner.py -> 'calls the benchmark'

Scheduling scripts :-

- upf-1.sh -> cfg-sys-1.sh -> common/sh/<machine_name> - module, scheduling, langs .sh files

## Infer workflow

This workflow assumes you have a data directory (called, say, DATA) containing run directories for processing with the new infer.py script

### Quick start

```
$ cd workflows/upf/test
# Edit upf-infer.sh to set the output EXPERIMENTS directory-
#   this will contain large output files
# Create upf-DATA.txt with the JSON fragments for the matching uq directories
#   Other glob patterns are fine too, this is handled by the shell
#   The output of this command is upf-DATA.txt, which could have any name
#   See mk-upf-infer.sh for full usage information
$ ./mk-infer-upf.sh upf-DATA.txt /path/to/DATA/uq.{40..100}
# Inspect upf-DATA.txt for sanity checking
# Run it:
$ ./upf-infer.sh cori upf-DATA.txt
```

### File index

- mk-infer-upf.sh: Assembles the JSON fragments into the UPF
- infer-template.json: M4 template for JSON fragments. Populated by environment variables set in mk-infer-upf.sh
- swift/workflow.{sh,swift}: Normal UPF workflow but newly extracts id from JSON template. The id is used as the run output directory

## Use from the supervisor tool

Be sure to set environment variable UPF to the name of your UPF file.
