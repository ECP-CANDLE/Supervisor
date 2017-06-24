# P3B1 mlrMBO Workflow #

The P3B1 mlrMBO workflow evaluates the P3B1 benchmark
using hyperparameters provided by a mlrMBO instance. mlrMBO
minimizes the validation loss. Swift is used to scalably distribute
work across the system, and EMEWS is used to:

1. Pass the hyperparameters to evaluate from the running mlrMBO algorithm to
the Swift script to launch a P3B1 run, and to
2. Pass the validation loss from a P3B1 run back to the running mlrBMO algorithm
 via the swift script.

For each run of the workflow, the following are produced:

* `final_res.Rds` - a serialized R object that
contains the final best parameter values and various metadata about the
parameter evaluations. This file will be written to the experiment directory (see below).
* `experiment_start.json` - a json file containing experiment (i.e. workflow)
level data (e.g. the start time, mlrMBO parameters, etc.). This will be
written to the experiment directory.
* `experiment_end.json` -  a json file containing experiment (i.e. workflow)
level data (e.g. the stop time, status info, etc). This will be
written to the experiment directory.

For each run of the benchmark model, the following is produced:

* `run.json` - a json file containing data describing the individual run: the
parameters for that run and per epoch details such as the validation loss. This
file will be written to the output directory for that particular run (e.g.)
`p3b1_mlrMBO/experiments/E1/run_1_1_0/output/run.json`.


## User requirements ##

What you need to install to run the workflow:

* This workflow - `git@github.com:ECP-CANDLE/Supervisor.git` .
  Clone and `cd` to `workflows/p3b1_mlrMBO`
  (the directory containing this README).
* p3b1 benchmark - `git@github.com:ECP-CANDLE/Benchmarks.git` .
  Clone and switch to the `frameworks` branch.
* P3B1 benchmark data - http://ftp.mcs.anl.gov/pub/candle/public/benchmarks/P3B1/P3B1_data.tgz.
`P3B1_data.tgz` should be untarred into `X/Benchmarks/Data/P3B1` where 'X'
is the parent directory path of your Benchmark repository.  For example, from
within `X/Benchmarks`. Note that the file must be named `P3B1_data.tgz.tar.gz` and remain in the
`X/Benchmarks/Data/P3B1` after untarring.

  ```
  mkdir -p Data/P3B1
  cd Data/P3B1
  wget  ftp://ftp.mcs.anl.gov/pub/candle/public/benchmarks/P3B1/P3B1_data.tgz -O P3B1_data.tgz.tar.gz
  tar -xf P3B1_data.tgz.tar.gz
  ```

## System requirements ##

These may already be installed on your system.
The CANDLE team has installed these on many popular supercomputers.

* Python 2.7, R 3.4
* Keras - https://keras.io. The frameworks branch of p3b1 should work with
both version 1 and 2.
* Swift/T with Python 2.7 and R enabled - http://swift-lang.org/Swift-T/
** Installation guide:
   http://swift-lang.github.io/swift-t/guide.html#_installation
* Required R packages:
  * All required R packages can be installed from within R with:
  ```
  install.packages(c("<package name 1>", "<package name 2", ...),
                   dependencies=TRUE)
  ```
  * Or with shell command `R -f install-mlrMBO.R`
  On ALCF: Use an HTTP mirror!
  Not one of the initially listed HTTPS mirrors, they are not accessible.
  * mlrMBO and dependencies : (https://mlr-org.github.io/mlrMBO/).
  https://cran.r-project.org/src/contrib/mlrMBO_1.0.0.tar.gz
  * parallelMap : (https://cran.r-project.org/web/packages/parallelMap/index.html)
  * DiceKriging and dependencies : (https://cran.r-project.org/web/packages/DiceKriging/index.html)
  * rgenoud : (https://cran.r-project.org/web/packages/rgenoud/index.html)
* Compiled EQ/R, instructions in `ext/EQ-R/eqr/COMPILING.txt`
** TL;DR: On Cori, type `ext/EQ-R/eqr/cori_build.sh`
* Install plotly 4.5.6 - not the latest (which tries to install shiny, which tries to install httpuv, which does not work on Cooley).

See below for instructions for running on specific machines (e.g. Cori, Theta)

## Workflow ##

The workflow project consists of the following directories.

```
p3b1_mlrMBO/
  data/
  ext/EQ-R
  etc/
  scripts/
  R/
  python/
  swift/
```

 * `data` - model input etc. data, such as the mlrMBO space description (e.g parameter_set3.R)
 * `etc` - additional code used by EMEWS
 * `ext/EQ-R` - swift-t EMEWS Queues R implementation (EQ/R) extension
 * `R/mlrMBO3.R` - the mlrMBO R code
 * `R/mlrMBO_utils.R` - utility functions used by the mlrMBO R code
 * `python/p3b1_runner.py` - python code called by the swift script to run P3B1.
 * `python/test/test.py` - python code for testing the p3b1_runner.
 * `swift/workflow3.swift` - the swift workflow script
 * `swift/workflow.sh` - generic launch script to set the appropriate enviroment variables etc. and then launch the swift workflow script
 * `swift/cori_workflow3.sh` - launch script customized for the Cori supercomputer
 * `swift/cori_settings.sh` - settings for running on the Cori supercomputer
 * `swift/ai_workflow.sh` - launch script for running the app invocation ("ai") workflow (see below).
 * `swift/ai_workflow3.swift` - app invocation version (see below) of the swift workflow
 * `swift/theta_workflow.sh` - launch script for running on theta. This uses the app invocation workflow.
 * `scripts/theta_run_model.sh` - theta-specific bash script used to launch p3b1_runner.py
 * `scripts/run_model.sh` - generic bash script used to to launch p3b1_runner.py

## Running the Workflow ##

There are two different version of the workflow.

1. The first runs the benchmark code directly from within swift using swift's
python integration.
2. The second, the _ai_-version, runs the benchmark code by invoking the python interpreter using
a bash script which is in turn invoked using a swift app function. The bash scripts
`scripts/theta_run_model.sh` and `scripts/run_model.sh` are an example of the
bash script.

The latter of these is necessary on machines like Theta where it is not possible
to compile swift with an appropriate python.

The launch scripts in the `swift` directory are used to run the workflow.
Backup the workflow launch script and edit it as appropriate. Typically,
you should only need to edit the values between `# USER SETTINGS START` and
`# USER SETTINGS END`. This includes the following shell variables:

* `BENCHMARK_DIR` - this should be set to the location of the P3B1 benchmark
* `MAX_BUDGET` - Maximum total number of model evaluations, including both design and iteration evaluations.
* `MAX_ITERATIONS` - Total number of iterative sampling rounds after the initial design sampling.
* `DESIGN_SIZE` - Total number of design points/evaluations in the initial sampling.
* `PROPOSE_POINTS` - Total number of evaluations within each iteration of the mbo algorithm.
* `PARAM_SET_FILE` - the file that defines the hyperparameter space used by R.

The latter 5 of these are passed directly to the swift script and retrieved
using the swift `argv()` builtin.

```
int propose_points = toint(argv("pp", "10"));
int max_budget = toint(argv("mb", "110"));
int max_iterations = toint(argv("mi", "10"));
int design_size = toint(argv("ds", "10"));
string param_set = argv("param_set_file");
```

If running on an HPC machine, set `PROCS`, `PPN`, `QUEUE`, `WALLTIME` and `MACHINE`
as appropriate.

Lastly, see the TODOs in the launch script for any additional variables to set.

### App Invocation Shell Variables ###

If you need to run the _ai_-version of the workflow, there are two additional shell
variables to set:

* `SCRIPT_FILE` - the path to the bash script that is used to launch the python
benchmark runner code (e.g. `scripts/run_model.sh`).
* `LOG_SCRIPT_FILE` - the path to the bash script that is used to launch the python
logging code code. By default these scripts are in the
`Supervisor/workflows/common/sh` directory as they can be shared among the
different workflows. See for example `Supervisor/workflows/common/sh/run_logger.sh`

### Running the *workflow script* ###

The workflow is executed by running the launch script and passing it an
'experiment id', i.e., `swift/workflow.sh <EXPID>` where `EXPID` is the
experiment ID (provide any token you want). The workflow
 output, various swift related files, and the `final_res.Rds` file will be written
 into a `p3b1_mlrMBO/experiments/X` directory where X is the experiment id. A copy
 of the launch script that was used to launch the workflow will also be written
 to this directory.

### Defining the Hyperparameter Space ###

The hyperparameter space is defined in by a small snippet of R code in the
the file defined by PARAM_SET_FILE (see above) shell variable. The R code
must set a `param.set` variable with
a mlrMBO parameter set description. For example:

```R
param.set <- makeParamSet(
  makeIntegerParam("epoch", lower = 2, upper = 6)
)
```

More information on the various functions that can be used to define the space
can be found at: http://berndbischl.github.io/ParamHelpers/man/

The hyperparameters sampled from the hyperparameter space by the mlrMBO algorithm
are passed to swift-t as set of semi-colon separated JSON strings. Swift-t then
splits these into individual JSON strings each of which contains the
parameters for a single run.

### final_res.Rds ###
mlrMBO's mbo function produces a MBOSingleObjResult object. That object is
saved to the file system in the experiment directory as `final_res.Rds`. The 'x'
attribute of this object will contain the best hyper parameter. Sample R
session:

```R
> res <- readRDS('~/Desktop/final_res.Rds')
> print(res)
Recommended parameters:
epoch=4
Objective: y = 0.037

Optimization path
4 + 12 entries in total, displaying last 10 (or less):
   epoch          y dob eol error.message exec.time ei error.model train.time
7      4 0.06319008   1  NA          <NA>   2746.58  0        <NA>         NA
8      6 0.06321167   1  NA          <NA>   2746.58  0        <NA>         NA
9      4 0.06323924   2  NA          <NA>   2777.96  0        <NA>      0.076
10     6 0.06342043   2  NA          <NA>   2777.96  0        <NA>         NA
11     6 0.06318849   2  NA          <NA>   2777.96  0        <NA>         NA
12     4 0.03745013   2  NA          <NA>   2777.96  0        <NA>         NA
13     2 0.06297304   3  NA          <NA>   1926.64  0        <NA>      0.075
14     3 0.06274078   3  NA          <NA>   1926.64  0        <NA>         NA
15     3 0.06298386   3  NA          <NA>   1926.64  0        <NA>         NA
16     4 0.06296253   3  NA          <NA>   1926.64  0        <NA>         NA
   prop.type propose.time           se       mean
7  infill_ei        0.141 0.000000e+00 0.06272000
8  infill_ei        0.150 2.572439e-12 0.06277278
9  infill_ei        0.150 0.000000e+00 0.06315830
10 infill_ei        0.154 0.000000e+00 0.06299223
11 infill_ei        0.138 0.000000e+00 0.06290148
12 infill_ei        0.145 0.000000e+00 0.06301220
13 infill_ei        0.147 3.292723e-10 0.06275064
14 infill_ei        0.168 0.000000e+00 0.06274738
15 infill_ei        0.148 0.000000e+00 0.05431496
16 infill_ei        0.147 0.000000e+00 0.05675149
> print(res$x)
$epoch
[1] 4

> print(res$y)
[1] 0.03745013
```
Note that without the mlrMBO etc. packages installed, you can load the object
but will not print etc. correctly.

For more information see, the mbo and MBOSingleObjResult in the mlrMBO
documentation: https://cran.r-project.org/web/packages/mlrMBO/mlrMBO.pdf

In addition to final_res.Rds, for each run the workflow writes out the hyperparameters
used in that run to a `parameters.txt` file in each run's instance directory.
`parameters.txt` can be used to run the model outside of the workflow using
the `--config_file` command line argument. For example,
`python p3b1_baseline_keras2.py --config_file parameters.txt`

### Running on Cori ###

* Download, install etc. the user requirements listed at the top of this
document.

All the system requirements (see above) have been installed on Cori except
for the EQ/R swift extension.

* Compile the EQ/R swift-t extension.
```
cd Supervisor/workflows/p3b1_mlrMBO/ext/EQ-R/eqr
./cori_build.sh
```

Launching the workflow:

Use the cori_* files in the `swift` directory to launch the workflow. Edit
`cori_workflow3.sh` setting the relevant variables as appropriate.  All easily
 changed settings are delineated by the `USER SETTINGS START` and `USER SETTINGS END`
markers.  Note that these variables can be easily overwritten from the calling
environment (use `export` in your shell). By default these are set up for short
debugging runs and will need to be changed for a production run.

An example:

```
cd Supervisor/workflows/p3b1_mlrMBO/swift
source cori_settings.sh
./cori_workflow.sh T1
```
where T1 is the experiment ID.

### Running on Theta ###

TODO
