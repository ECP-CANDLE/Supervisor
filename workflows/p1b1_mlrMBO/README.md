# P1B1 mlrMBO Workflow #

The P1B1 mlrMBO workflow evaluates a modified version of the P1B1 benchmark
autoencoder using hyperparameters provided by a mlrMBO instance. The P1B1
code (p1b1_baseline.py) has been modified to expose a functional interface.
The neural net remains the same. Currently, mlrMBO minimizes the validation
loss. EMEWS R queues are used to:
1. pass the hyperparameters to evaluate from the running mlrMBO algorithm to the swift script to launch a p1b1 run, and to
2. pass the validation loss from a p1b1 run back to the running mlrBMO algorithm via the swift script.

The workflow ultimately produces a `final_res.Rds` serialized R object that
contains the final best parameter values and various metadata about the
parameter evaluations.

 ## Requirements ##

* Python 2.7
* P1B1 Autoencoder - git@github.com:ECP-CANDLE/Benchmarks.git. Clone and switch
to the supervisor branch.
* P1B1 Data - `http://ftp.mcs.anl.gov/pub/candle/public/benchmarks/P1B1/P1B1.train.csv` and `http://ftp.mcs.anl.gov/pub/candle/public/benchmarks/P1B1/P1B1.test.csv`. Download these into some suitable directory (e.g. `workflows/p1b1_mlrMBO/data`)
* Keras - https://keras.io. The supervisor branch of P1B1 should work with
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
p1b1_mlrMBO/
  data/
  ext/EQ-R
  etc/
  R/
  python/
  swift/
```

 * `data` - model input etc. data, such as the hyperopt space description.
 * `etc` - additional code used by EMEWS
 * `ext/EQ-R` - swift-t EMEWS Queues R implementation (EQ/R) extension
 * `R/mlrMBO.R` - the mlrMBO R code
 * `R/mlrMBO_utils.R` - utility functions used by the mlrMBO R code
 * `python/p1b1_runner.py` - python code called by the swift script to run p1b1.
 * `python/test/test.py` - python code for testing the p1b1_runner.
 * `swift/workflow.swift` - the swift workflow scrip
 * `swift/workflow.sh` - generic launch script to set the appropriate enviroment variables etc. and then launch the swift workflow script
 * `swift/cooley_workflow.sh` - launch script customized for the Cooley supercomputer


 ## Running the Workflow ##

 The launch scripts in the `swift` directory can be used to run the workflow.
 Copy the `workflow.sh` and edit it as appropriate. The swift script takes
 4 arguments, each of which is set in the launch script.

 * MAX_CONCURRENT_EVALUATIONS - the number of evaluations (i.e p1b1 runs) to
 perform each iteration.
 * ITERATIONS - the total number of iterations to perform. The total number of
 p1b1 runs performed will be ITERATIONS * MAX_CONCURRENT_EVALUATIONS + mlrMBO's
 initial set of "design" runs.
 * PARAM_SET_FILE - the path of the file that defines mlrMBO's hyperparameter space (e.g. EMEWS_PROJECT_ROOT/data/parameter_set.R).
 * DATA_DIRECTORY - the directory containing the test and training data. The files themselves are assumed to be named `P1B1.train.csv` and `P1B1.test.csv`

 Also see the TODOs in the launch script for additional variables to set.

 The launch script also sets PYTHONPATH to include the location of the P1B1
 python code. Edit P1B1_DIR as appropriate.

 The launch script takes as a required argument an experiment id. The workflow
 output, various swift-t related files, and the `final_res.Rds` file will be written into a `p1b1_mlrMBO\experiments\X`
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
are unpacked in `python/p1b1_runner.py`. If the hyperparameter space is
changed then that code will need to be changed as well. For example,

```R
param.set <- makeParamSet(
  makeIntegerParam('epoch', lower = 2, upper = 5),
  makeIntegerParam('batch_size', lower = 50, upper = 100)
)
```
yields a parameter comma separated string, passed to p1b1_runner.run() that
looks like like "4, 62" where epoch is 4 and batch_size is 62. And, the
code to parse the string would look like

```python
params = parameter_string.split(',')
epochs = int(params[0].strip())
batch_size = int(params[1].strip())
```

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


## Running on Cooley ##

Prerequisites:

* Install the required R packages. When R displays the list of mirrors to chose from, use an HTTP mirror!
  Not one of the initially listed HTTPS mirrors, they are not accessible.
```
soft add +gcc-4.8.1
export PATH=/home/wozniak/Public/sfw/x86_64/R-3.2.3-gcc-4.8.1/lib64/R/bin:$PATH
R -f install-mlrMBO.R
```

* Compile the EQ/R swift-t extension:
  ```
  soft add +gcc-4.8.1
  export PATH=/home/wozniak/Public/sfw/x86_64/tcl-8.6.6-global-gcc-4.8.1/bin:$PATH
  cd pl1b1_mlrMBO/ext/EQ-R/eqr
  cp settings.template.sh settings.sh
  ```
  In settings.sh, set the R and tcl related variables as follows:

  ```
  R_INCLUDE=/home/wozniak/Public/sfw/x86_64/R-3.2.3-gcc-4.8.1/lib64/R/include
  R_LIB=/home/wozniak/Public/sfw/x86_64/R-3.2.3-gcc-4.8.1/lib64/R/lib
  R_INSIDE=/home/wozniak/Public/sfw/x86_64/R-3.2.3-gcc-4.8.1/lib64/R/library/RInside
  RCPP=/home/wozniak/Public/sfw/x86_64/R-3.2.3-gcc-4.8.1/lib64/R/library/Rcpp

  TCL_INCLUDE=/home/wozniak/Public/sfw/x86_64/tcl-8.6.6-global-gcc-4.8.1/include
  TCL_LIB=/home/wozniak/Public/sfw/x86_64/tcl-8.6.6-global-gcc-4.8.1/lib
  TCL_LIBRARY=tcl8.6
  ```
  Then

  ```
  soft add +autotools
  ./bootstrap
  source settings.sh
  ./configure
  make install
  ```
* Cooley uses this python: `/soft/analytics/conda/env/Candle_ML/lib/python2.7/` with
keras etc. already installed, so nothing needs to be done there.

* Launching the workflow

Edit cooley_workflow.sh, setting the relevant variables (see above) as appropriate.

```
export PATH=/home/wozniak/Public/sfw/x86_64/login/swift-t-conda-r/stc/bin:$PATH
cd p1b1_mlrMBO/swift
./cooley_workflow T1
```
where T1 is the experiment id.
