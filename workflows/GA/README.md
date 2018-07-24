# GA (genetic algorithm) based based hyperparameter optimization on CANDLE Benchmarks #

The GA workflow uses the Python deap package (http://deap.readthedocs.io/en/master) to optimize hyperparameters using a genetic algorithm. 

## Running ##

1. cd into the **Supervisor/workflows/GA/test** directory
2. Specify the GA parameters in the **cfg-prm-1.sh** file (see [below](#structure) for more information on the GA parameters)
3. Specify the PROCS, QUEUE etc. in **cfg-sys-1.sh** file
4. You will pass the MODEL_NAME, SITE, and optional experiment id arguments to **test-1.sh** file when launching:
`./test-1.sh <model_name> <machine_name> [expid]`
where `model_name` can be tc1 etc., `machine_name` can be local, cori, theta, titan etc. (see [NOTE](#making_changes) below on creating new SITE files.)
5. Update the parameter space json file if necessary. The parameter space is defined in json file (see **workflows/GA/data/tc1_param_space_ga.json** for an example with tc1). The
**cfg-prm-1.sh** script will attempt to select the correct json given the model name. Edit that file as appropriate. The parameter space json file is further described [here](#config) 
6. The benchmark will be run for the number of processors specified
7. Final objective function values, along with parameters, will be available in the experiments directory in a **finals_results** file and also printed to standard out.


## User requirements ##

What you need to install to run the workflow:

* This workflow - `git@github.com:ECP-CANDLE/Supervisor.git` .
  Clone and switch to the `master` branch. Then `cd` to `workflows/GA`
  (the directory containing this README).
* TC1 or other benchmark - `git@github.com:ECP-CANDLE/Benchmarks.git` .
  Clone and switch to the `frameworks` branch.
* benchmark data -
 See the individual benchmarks README for obtaining the initial data

 Python specific installation requirements:

1. pandas
2. deap

These may be already part of the existing python installation. If not these can be installed using `conda` or `pip`. They
must be installed using the same python installation used by swift-t. A `swift-t -v` will print the python that swift-t has embedded.

If any required python packages must be installed locally, then you will probably need to add your local site-packages
directory to the PYTHONPATH specified in **cfg-sys-1.sh**. For example,

`export PYTHONPATH=/global/u1/n/ncollier/.local/cori/deeplearning2.7/lib/python2.7/site-packages`


## Calling sequence ##

Function calls:
```
test-1.sh -> swift/workflow.sh ->

      (GA via EQPy)
      swift/workflow.swift -> common/python/deap_ga.py

      (Benchmark)
      swift/workflow.swift -> common/swift/obj_app.swift ->
      common/sh/model.sh -> common/python/model_runner.py -> 'calls Benchmark'

      (Results from Benchmark returned to the GA via EQPy)
      common/swift/obj_app.swift -> swift/workflow.swift ->
      common/python/deap_ga.py
```

Scheduling scripts:
```
test-1.sh -> cfg-sys-1.sh ->
      common/sh/<machine_name> - module, scheduling, langs .sh files
```
## Making Changes <a name="making_changes"></a>

To create your own SITE files in workflows/common/sh/:
- langs-SITE.sh
- langs-app-SITE.sh
- modules-SITE.sh
- sched-SITE.sh config

copy existing ones but modify the langs-SITE.sh file to define the EQPy location (see workflows/common/sh/langs-local-as.sh for an example).

### Structure <a name="structure"></a>###

The point of the script structure is that it is easy to make copy and modify the `test-*.sh` script, and the `cfg-*.sh` scripts.  These can be checked back 
into the repo for use by others.  The `test-*.sh` script and the `cfg-*.sh` scripts should simply contain environment variables that control how `workflow.sh` 
and `workflow.swift` operate.

`test-1.sh` and `cfg-{sys,prm}-1.sh` should be unmodified for simple testing.

The relevant parameters for the GA algorithm are defined in `cfg-prm-*.sh` scripts (see example in `cfg-prm-1.sh`). These are:
- SEED: The random seed used by deap in the GA.
- NUM_ITERATIONS: The number of iterations the GA should perform.
- POPULATION_SIZE: The maximum number of hyperparameter sets to evaluate in each iteration. 
GA_STRATEGY: The algorithm used by the GA. Can be one of "simple" or "mu_plus_lambda". See eaSimple and eaMuPlusLambda at https://deap.readthedocs.io/en/master/api/algo.html?highlight=eaSimple#module-deap.algorithms for more information.

### Hyperparameter Configuration File <a name="config"></a>###

The GA workflow uses a json format file for defining the hyperparameter space. The GA workflow comes with 4 sample hyperparameter spaces in the `GA/data` directory, one each for the combo, nt3, p1b1 and tc1 benchmarkts.

The hyperparameter configuration file has a json format consisting of a
list of json dictionaries, each one of which defines a hyperparameter. Each dictionary has the following required keys:

* name: the name of the hyperparameter (e.g. *epochs*)
* type: determines how the initial population (i.e. the hyperparameter sets) are initialized from the named parameter and how those values are subsequently mutated by the GA. Type is one of `constant`, `int`, `float`, `logical`, `categorical`, or `ordered`.
  * `constant`: 
    * each model is initialized with the same specifed value
    * mutation always returns the same specified value
  * `int`: 
    * each model is initialized with an int randomly drawn from the range defined by `lower` and `upper` bounds
    * mutation is peformed by adding the results of a random draw from 
    a gaussian distribution to the current value, where the gaussian distribution's mu is 0 and its sigma is specified by the `sigma` entry.
  * `float`: 
    * each model is initialized with a float randomly drawn from the range defined by `lower` and `upper` bounds
    * mutation is peformed by adding the results of a random draw from 
    a gaussian distribution to the current value, where the gaussian distribution's mu is 0 and its sigma is specified by the `sigma` entry.
  * `logical`: 
    * each model is initialized with a random boolean.
    * mutation flips the logical value
  * `categorical`: 
    * each model is initialized with an element chosen at random from the list of elements in `values`.
    * mutation chooses an element from the `values` list at random
  * `ordered`: 
    * each model is inititalized with an element chosen at random from the list of elements in `values`.
    * given the index of the current value in the list of `values`, mutation selects the element *n* number of indices away, where n is the result of a random draw between 1 and `sigma` and then is negated with a 0.5 probability.

The following keys are required depending on value of the `type` key.

If the `type` is `constant`:
  * `value`: the constant value

If the `type` is `int`, or `float`:
  * `lower`: the lower bound of the range to draw from
  * `upper`: the upper bound of the range to draw from
  * `sigma`: the sigma value used by the mutation operator (see above).

If the `type` is `categorical`:
  * `values`: the list of elements to choose from
  * `element_type`: the type of the elements to choose from. One of `int`, `float`, `string`, or `logical`

If the `type` is `ordered`:
  * `values`: the list of elements to choose from
  * `element_type`: the type of the elements to choose from. One of `int`, `float`, `string`, or `logical`
  * `sigma`: the sigma value used by the mutation operator (see above).

A sample hyperparameter definition file:

```javascript
[
  {
    "name": "activation",
    "type": "categorical",
    "element_type": "string",
    "values": ["softmax", "elu", "softplus", "softsign", "relu", "tanh", "sigmoid", "hard_sigmoid", "linear"]
  },

  {
    "name": "optimizer",
    "type": "categorical",
    "element_type": "string",
    "values": ["adam", "rmsprop"]
  },

  {
    "name": "lr",
    "type": "float",
    "lower": 0.0001,
    "upper": 0.01,
    "sigma": "0.000495"
  },

  {
    "name": "batch_size",
    "type": "ordered",
    "element_type": "int",
    "values": [16, 32, 64, 128, 256],
    "sigma": 1
  }
]
```

Note that any other keys are ignored by the workflow but can be used to add additional information about the hyperparameter. For example, the sample files
contain a `comment` entry that contains additional information about that hyperparameter.

### Where to check for output ###

This includes error output.

When you run the test script, you will get a message about `TURBINE_OUTPUT` .  This will be the main output directory for your run.

* On a local system, stdout/stderr for the workflow will go to your terminal.
* On a scheduled system, stdout/stderr for the workflow will go to `TURBINE_OUTPUT/output.txt`

The individual objective function (model) runs stdout/stderr go into directories of the form:

`TURBINE_OUTPUT/EXPID/run/RUNID/model.log`

where `EXPID` is the user-provided experiment ID, and `RUNID` are the various model runs generated by async-search, one per parameter set, of the form `R_I_J` where `R` is the restart number, `I` is the iteration number, and `J` is the sample within the iteration.

Each successful run of the workflow will produce a `final_results_2` file. The first line of the file contains the GA's final population, that is, the final hyperparameter sets. The second line contains the final score (e.g. val loss) for each parameter set. The remainder of the file reports the GA's per iteration statistics. The columns are:

- gen: the generation / iteration
- nevals: the number of evaluations performed in this generation. In generations after the first, this may be less the total population size as some combinations will already have been evaluated.
- avg: the average score
- std: the standard deviation 
- min: the minimum score
- max: the maximum score
- ts: a timestamp recording when this generation finished. The value is the number of seconds since the epoch in floating point format



