# P1B3 mlrMBO Workflow #

The P1B3 mlrMBO workflow evaluates the P1B3 benchmark
using hyperparameters provided by a mlrMBO instance. mlrMBO
minimizes the validation loss. EMEWS R queues are used to:

1. pass the hyperparameters to evaluate from the running mlrMBO algorithm to the swift script to launch a P1B3 run, and to
2. pass the validation loss from a P1B3 run back to the running mlrBMO algorithm via the swift script.

Currently, this example is working with the keras based code and does not yet
work with mxnet or neon.

The workflow ultimately produces a `final_res.Rds` serialized R object that
contains the final best parameter values and various metadata about the
parameter evaluations.

## User requirements ##

What you need to install to run the workflow:

* P1B3 benchmark - `gi<nolink>t@github.com:ECP-CANDLE/Benchmarks.git` . Clone and switch to the `frameworks` branch.


## System requirements ##

These may already be installed on your system

* Python 2.7
* Keras - https://keras.io. The supervisor branch of P1B3 should work with
both version 1 and 2.
* Swift-t with Python 2.7 and R enabled - http://swift-lang.org/Swift-T/
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

Install plotly 4.5.6 - not the latest (which tries to install shiny, which tries to install httpuv, which does not work on Cooley).

## Workflow ##

The workflow project consists of the following directories.

```
P1B3_mlrMBO/
  data/
  ext/EQ-R
  etc/
  R/
  python/
  swift/
```

 * `data` - model input etc. data, such as the mlrMBO space description.
 * `etc` - additional code used by EMEWS
 * `ext/EQ-R` - swift-t EMEWS Queues R implementation (EQ/R) extension
 * `R/mlrMBO.R` - the mlrMBO R code
 * `R/mlrMBO_utils.R` - utility functions used by the mlrMBO R code
 * `python/P1B3_runner.py` - python code called by the swift script to run P1B3.
 * `python/test/test.py` - python code for testing the P1B3_runner.
 * `swift/workflow.swift` - the swift workflow scrip
 * `swift/workflow.sh` - generic launch script to set the appropriate enviroment variables etc. and then launch the swift workflow script
 * `swift/cori_workflow.sh` - launch script customized for the Cori supercomputer
 * `swift/cori_settings.sh` - settings for running on the Cori supercomputer

 ## Running the Workflow ##

 The launch scripts in the `swift` directory can be used to run the workflow.
 Copy the `workflow.sh` and edit it as appropriate. The swift script takes
 3 arguments, each of which is set in the launch script.

 * MAX_CONCURRENT_EVALUATIONS - the number of evaluations (i.e P1B3 runs) to
 perform each iteration.
 * ITERATIONS - the total number of iterations to perform. The total number of
 P1B3 runs performed will be ITERATIONS * MAX_CONCURRENT_EVALUATIONS + mlrMBO's
 initial set of "design" runs.
 * PARAM_SET_FILE - the path of the file that defines mlrMBO's hyperparameter space (e.g. EMEWS_PROJECT_ROOT/data/parameter_set.R).

 Also see the TODOs in the launch script for additional variables to set.

 The launch script also sets PYTHONPATH to include the location of the P1B3
 python code. Edit P1B3_DIR as appropriate.

 The launch script takes as a required argument an experiment id. The workflow
 output, various swift-t related files, and the `final_res.Rds` file will be written into a `P1B3_mlrMBO\experiments\X`
 directory where X is the experiment id. A copy
 of the launch script that was used to launch the workflow will also be written
 to this directory.

 If running on a cluster or HPC machine, edit QUEUE, WALLTIME

### Defining the Hyperparameter Space ###

The hyperparameter space is defined in by a small snippet of R code in the
PARAM_SET_FILE (see above). The R code must set a `param.set` variable with
an mlrMBO parameter set description. For example:

```R
param.set <- makeParamSet(
  makeIntegerParam("epoch", lower = 2, upper = 6)
)
```

More information on the various functions that can be used to define the space
can be found at: http://berndbischl.github.io/ParamHelpers/man/

The hyperparameters sampled from the hyperparameter space by the mlrMBO algorithm
are passed to swift-t as semi-colon separated as JSON strings. Swift-t then
splits these into individual JSON strings each of which contains the
parameters for a single run.

**Note** `swift\workflow.swift` may have some default hyperparameters parameters
set in the template code for debugging purposes:

```
hyper_parameter_map['feature_subsample'] = 500
hyper_parameter_map['train_steps'] = 100
hyper_parameter_map['val_steps'] = 10
hyper_parameter_map['test_steps'] = 10
```

These should be removed when doing a production run.

### final_res.Rds ###
mlrMBO's mbo function produces a MBOSingleObjResult object. That object is
saved to the file system in the experiment directory as final_res.Rds. The 'x'
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

### Running on Cori ###

Prerequisites:

* Install the required R packages. mlrMBO is installed, but DiceKriging and
rgenoud need to be installed.
```
module swap PrgEnv-intel PrgEnv-gnu
export PATH=/global/u1/w/wozniak/Public/sfw/R-3.4.0/lib64/R/bin:$PATH
R -f cori-install-mlrMBO.R
```

* Compile the EQ/R swift-t extension.
```
cd Supervisor/workflows/p1b3_mlrMBO/ext/EQ-R/eqr
./cori_build.sh
```

Launching the workflow:

Use the cori_* files in the `swift` directory to launch the workflow. Edit
`cori_workflow.sh` setting the relevant variables (see above) as appropriate.
By default these are set up for short debugging runs and will need to be
changed for a production run.

```
cd Supervisor/workflows/p1b3_mlrMBO/swift
source cori_settings.sh
./cori_workflow T1
```
where T1 is the experiment ID.
