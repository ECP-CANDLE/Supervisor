# Combo mlrMBO Workflow #

The Combo mlrMBO workflow evaluates a modified version of the Combo benchmark
autoencoder and variational autoencoder using hyperparameters provided by a mlrMBO instance. The Combo
code (combo_baseline_keras2.py) has been modified to expose a functional interface.
The neural net remains the same. Currently, mlrMBO minimizes the validation
loss. EMEWS R queues are used to:
1. pass the hyperparameters to evaluate from the running mlrMBO algorithm to the swift script to launch a combo run, and to
2. pass the validation loss from a combo run back to the running mlrBMO algorithm via the swift script.

The workflow ultimately produces a `final_res.Rds` serialized R object that
contains the final best parameter values and various metadata about the
parameter evaluations.

 ## Requirements ##

* Python 2.7
* Combo Autoencoder - git@github.com:ECP-CANDLE/Benchmarks.git. Clone and switch
to the frameworks branch.

mkdir -p Data/Pilot1
cd Data/Pilot1

* Combo benchmark data -
  ```
  wget http://ftp.mcs.anl.gov/pub/candle/public/benchmarks/Combo/descriptors.2D-NSC.5dose.filtered.txt
  wget http://ftp.mcs.anl.gov/pub/candle/public/benchmarks/Combo/GSE32474_U133Plus2_GCRMA_gene_median.txt
  wget http://ftp.mcs.anl.gov/pub/candle/public/benchmarks/Combo/ComboDrugGrowth.txt
  wget http://ftp.mcs.anl.gov/pub/candle/public/benchmarks/Combo/NCI60_CELLNAME_to_Combo.txt
  wget http://ftp.mcs.anl.gov/pub/candle/public/benchmarks/Combo/lincs1000.tsv
  wget http://ftp.mcs.anl.gov/pub/candle/public/benchmarks/Combo/type_18_300_train.csv
  wget http://ftp.mcs.anl.gov/pub/candle/public/benchmarks/Combo/type_18_300_train.csv
  ```
  `All the above files` should be copied into X/Benchmarks/Data/Pilot1,
  where X is the parent directory path of your Benchmark repository.  For example, from within `X/Benchmarks`

  ```


* Keras - https://keras.io. The supervisor branch of Combo should work with
both version 1 and 2.
* Swift-t with Python 2.7 and R enabled - http://swift-lang.org/Swift-T/
* Required R packages: (DO WE STILL NEED THIS? -Justin)
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
combo_mlrMBO/
  data/
  python/
  test/
  swift/
```

 * `data` - model input etc. data, such as the hyperopt space description.
 * `../common/ext/EQ-R` - swift-t EMEWS Queues R implementation (EQ/R) extension
 * `python/combo_runner.py` - python code called by the swift script to run combo.
 * `python/test/test.py` - python code for testing the combo_runner.
 * `swift/workflow.swift` - the swift workflow scrip
 * `swift/workflow.sh` - generic launch script to set the appropriate enviroment variables etc. and then launch the swift workflow script
 * `test` - run the shell script with site name - local/theta/titan/cori or other supported supercomputers 


 ## Running the Workflow ##

 The launch scripts in the `test` directory can be used to run the workflow.
 Copy the `cfg-prm.sh` 'cfg-sys.sh' and 'test-1.sh' and edit it as appropriate. 
 The test script takes 2 or 3 arguments, each of which is set in the launch script.

 ./test-1.sh titan OPTIONAL: <run directory>
 Eg.  ./test-1.sh titan /lustre/scratch/csc249/combo_runs/test-run1/

 If run directory is not specified new folder in experiments folder is created.

 'cfg-prm.sh' contains the following variables:

 * MAX_CONCURRENT_EVALUATIONS - the number of evaluations (i.e combo runs) to
 perform each iteration.
 * ITERATIONS - the total number of iterations to perform. The total number of
 combo runs performed will be ITERATIONS * MAX_CONCURRENT_EVALUATIONS + mlrMBO's
 initial set of "design" runs.
 * PARAM_SET_FILE - the path of the file that defines mlrMBO's hyperparameter space (e.g. EMEWS_PROJECT_ROOT/data/parameter_set.R).
 * DATA_DIRECTORY - the directory containing the test and training data and other essential files
 * PROPOSE_POINTS - number of points in each subsequent iteration
 * DESIGN_SIZE - initial number of runs required

 Also see the TODOs in the launch script for additional variables to set.

 The launch script takes as a required argument an experiment id. The workflow
 output, various swift-t related files, and the `final_res.Rds` file will be written into a `combo_mlrMBO\experiments\X`
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
are unpacked in `python/combo_runner.py`. If the hyperparameter space is
changed then that code will need to be changed as well. For example,

```R
param.set <- makeParamSet(
  makeIntegerParam('epoch', lower = 2, upper = 5),
  makeIntegerParam('batch_size', lower = 50, upper = 100)
)
```
yields a parameter comma separated string, passed to combo_runner.run() that
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


## Running on Theta/Titan/Cori/Local etc ##

* Launching the workflow on theta

Edit cfg-sys and cfg-prm.sh file for setting the relevant variables.

```
cd combo_mlrMBO/test
./test-1.sh theta
```
