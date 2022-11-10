# Simple Example of EMEWS Integration with mlrMBO

This directory contains a simple example of integrating mlrMBO with
EMEWS.

Requirements:

- R 3.2+
- All required R packages can be installed with
  `install.packages("<package name>")`
  - mlrMBO and dependencies : (https://mlr-org.github.io/mlrMBO/).
  - parallelMap : (https://cran.r-project.org/web/packages/parallelMap/index.html)
  - DiceKriging and dependencies : (https://cran.r-project.org/web/packages/DiceKriging/index.html)
  - rgenoud : (https://cran.r-project.org/web/packages/rgenoud/index.html)
  - testthat (for testing) : (https://cran.r-project.org/web/packages/testthat/index.html)
- Swift/T with R extension
- Compiled EQ/R, instructions in `ext/EQ-R/eqr/COMPILING.txt`

Run the example with `./swift_run_eqr.sh <experiment_ID>`. That assume that swift-t is in your PATH already.

## Workflow details

The workflow attempts to minimize the example function `sum(x^2)` for a two dimensional space `(x1,x2)` defined by the variables:

```R
"x1": lower = -5, upper = 5
"x2": lower = -10, upper = 20
```

and using existing capabilities from mlrMBO:

- **expected improvement** for the infill criterion
- **constant liar** for multi-point proposals

The example uses **multi-point proposals** for concurrency in the iterative steps, defined via a `pp=<number of proposed points>` argument within the `swift/swift_run_eqr.sh` script. Maximum algorithm iteration is defined via a `it=<number of max iterations>` argument, also within the `swift/swift_run_eqr.sh` script.

The mlrMBO algorithm is defined in `R/simple_mlrMBO.R` and it controls the overall EMEWS workflow through the EQ/R extension. It is initialized via a call to `EQR_init_script` in `swift/swift_run_eqr.swift`.

As indicated above, the workflow is run with `./swift_run_eqr.sh <experiment_ID>`. When the workflow completes, the results from running `mbo` are saved to the experiment directory in `experiments/experiment_ID/final_res.Rds` and can be loaded within an R session using `readRDS("<path to>/final_res.Rds")`.

## Testing the R components

The `R/test` directory contains tests for the R components in the workflow and for running the mlrMBO algorithm without Swift/T.

- `mlrMBO_utils_tests.R`: unit tests for `R/mlrMBO_utils.R`, which provides R components to the workflow (run using the testthat library's `test_file("<path to>/mlrMBO_utils_tests.R")` function)
- `simple_mlrMBO_run_test.R`: script that provides R implementations for the EQ/R `OUT_put` and `IN_get` calls to be able to run `R/simple_mlrMBO.R` at smaller scales for testing without Swift/T (run from the `R` directory via `source("test/simple_mlrMBO_run_test.R")`)
- `test_utils_tests.R`: tests for functions in `R/test/test_utils.R` which are used to make `simple_mlrMBO_run_test.R` work (run using `test_file("<path to>/test_utils_tests.R")`)

_(Below is the information that was generated when the simple_mlrMBO_example EMEWS project was created.)_

## EMEWS project template

You have just created an EMEWS project.
The project consists of the following directories:

```
simple_mlrMBO_example/
  data/
  ext/
  etc/
  python/
    test/
  R/
    test/
  scripts/
  swift/
  README.md
```

The directories are intended to contain the following:

- `data` - model input etc. data
- `etc` - additional code used by EMEWS
- `ext` - swift-t extensions such as eqpy, eqr
- `python` - python code (e.g. model exploration algorithms written in python)
- `python/test` - tests of the python code
- `R` - R code (e.g. model exploration algorithms written R)
- `R/test` - tests of the R code
- `scripts` - any necessary scripts (e.g. scripts to launch a model), excluding
  scripts used to run the workflow.
- `swift` - swift code

Use the subtemplates to customize this structure for particular types of
workflows. These are: sweep, eqpy, and eqr.
