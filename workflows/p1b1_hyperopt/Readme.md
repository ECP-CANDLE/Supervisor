# P1B1 hyperopt Workflow #

The P1B1 hyperopt workflow evaluates a modified version of the P1B1 benchmark
autoencoder using hyperparameters provided by a hyperopt instance. The P1B1
code (p1b1_baseline.py) has been modified to expose a functional interface.
The neural net remains the same. Currently, hyperopt minimizes the validation
loss.

Requirements:

* Python 2.7
* P1B1 Autoencoder - git@github.com:ECP-CANDLE/Benchmarks.git. Clone and switch
to the supervisor branch.
* P1B1 Data - `http://ftp.mcs.anl.gov/pub/candle/public/benchmarks/P1B1/P1B1.train.csv` and `http://ftp.mcs.anl.gov/pub/candle/public/benchmarks/P1B1/P1B1.test.csv`. Download these into some suitable directory (e.g. `workflows/p1b1_hyperopt/data`)
* Hyperopt - http://hyperopt.github.io/hyperopt/
* Keras - https://keras.io. The supervisor branch of P1B1 should work with
both version 1 and 2.
* Swift-t with Python 2.7 enabled - http://swift-lang.org/Swift-T/

This workflow also uses code included in this repository: the EMEWS EQ/Py extension
(`workflows/p1b1_hyperopt/ext/EQ-Py`) and the eqpy hyperopt bridge code
(`python/hyperopt/eqpy_hyperopt`).

The workflow project consists of the following directories.

```
p1b1_hyperopt/
  data/
  ext/EQ-Py
  etc/
  swift/
```

 * `data` - model input etc. data, such as the hyperopt space description.
 * `etc` - additional code used by EMEWS
 * `ext/EQ-Py` - swift-t EQ\Py extension
 * `swift/workflow.swift` - the swift workflow script
 * `swift/workflow.sh` - generic launch script to set the appropriate enviroment variables etc. and then launch the swift workflow script
 * `swift/cori_settings.sh` - settings specific to the Cori supercomputer
 * `swift/cori_workflow.sh` - launch script customized for the Cori supercomputer
 * `swift/cooley_workflow.sh` - launch script customized for the Cooley supercomputer


 ## Running the Workflow ##

 The launch scripts in the `swift` directory can be used to run the workflow.
 Copy the `workflow.sh` and edit it as appropriate. The swift script takes
 4 arguments, each of which is set in the launch script.

 * EVALUATIONS - the total number of runs to perform
 * PARAM_BATCH_SIZE - the number of hyperparameter sets to evaluate in parallel. Hyperopt will produce this many sets of hyperparameters each iteration until EVALUATIONS has been reached.
 * SPACE_FILE - the path of the file that defines hyperopt's hyperparameter space (e.g. EMEWS_PROJECT_ROOT/data/space_description.txt)
 * DATA_DIRECTORY - the directory containing the test and training data. The files themselves are assumed to be named `P1B1.train.csv` and `P1B1.test.csv`

The launch script also sets PYTHONPATH to include the swift-t EQ-Py extension,
the eqpy hyperopt bridge, and the location of the P1B1 python code. Only the
location of the P1B1 python may need to be changed. Edit P1B1_DIR as appropriate.

The launch script takes as a required argument an experiment id. The workflow
output, various swift-t related files, and a `final_result` file that contains the
best set of hyper-parameters will be written into a `p1b1_hyperopt\experiments\X`
directory where X is the experiment id. A copy
of the launch script that was used to launch the workflow will also be written
to this directory.

### Running on Cori ###
0. The Cori workflow uses Cori's existing deeplearing environment. This includes
Keras, but NOT hyperopt. To install hyperopt, if you haven't already:

    ```
  module load deeplearning
  pip install --user hyperopt
    ```
1. Source the `swift/cori_settings.sh` file to load the required modules etc:

    ```source cori_settings```

2. In the swift directory, run the `cori_workflow.sh` launch script with an
experiment id. For example,

 ```./cori_workflow.sh T1```

### Running on Cooley ###
0. Cooley uses this python: `/soft/analytics/conda/env/Candle_ML/lib/python2.7/` with
hyperopt, keras etc. already installed.
1. Add this Swift/T to your PATH: `~wozniak/Public/sfw/x86_64/login/swift-t-conda/stc/bin`
2. In the swift directory, run the `cooley_workflow.sh` launch scrip with an
experiment id. For example,

  ```./cooley_workflow.sh T1```
