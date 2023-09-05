
# GA (genetic algorithm) based based hyperparameter optimization on CANDLE Benchmarks

The GA workflow uses the Python deap package (http://deap.readthedocs.io/en/master) to optimize hyperparameters using a genetic algorithm.

## Running

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

## User requirements

What you need to install to run the workflow:

- This workflow - `git@github.com:ECP-CANDLE/Supervisor.git` .
  Clone and switch to the `master` branch. Then `cd` to `workflows/GA`
  (the directory containing this README).
- TC1 or other benchmark - `git@github.com:ECP-CANDLE/Benchmarks.git` .
  Clone and switch to the `frameworks` branch.
- benchmark data -
  See the individual benchmarks README for obtaining the initial data

Python specific installation requirements:

1. pandas
2. deap

These may be already part of the existing python installation. If not these can be installed using `conda` or `pip`. They
must be installed using the same python installation used by swift-t. A `swift-t -v` will print the python that swift-t has embedded.

If any required python packages must be installed locally, then you will probably need to add your local site-packages
directory to the PYTHONPATH specified in **cfg-sys-1.sh**. For example,

`export PYTHONPATH=/global/u1/n/ncollier/.local/cori/deeplearning2.7/lib/python2.7/site-packages`

## Calling sequence

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

## The supervisor interface

Command line:
```
$ supervisor SITE WORKFLOW TEST_SCRIPT
```

Variables that can be set in the TEST_SCRIPT

MODEL_NAME
PARAM_SET_FILE
SEED
EXPID
NUM_ITERATIONS
POPULATION_SIZE
GA_STRATEGY
OFFSPRING_PROP
MUT_PROB
CX_PROB
MUT_INDPB
CX_INDPB
TOURNSIZE

PROCS
PPN
WALLTIME
PROJECT
QUEUE
BENCHMARK_TIMEOUT

## Making Changes <a name="making_changes"></a>

To create your own SITE files in workflows/common/sh/:

- langs-SITE.sh
- langs-app-SITE.sh
- modules-SITE.sh
- sched-SITE.sh config

copy existing ones but modify the langs-SITE.sh file to define the EQPy location (see workflows/common/sh/langs-local-as.sh for an example).

### Structure <a name="structure"></a>###

The point of the script structure is that it is easy to make copy and modify the `test-*.sh` script, and the `cfg-*.sh` scripts. These can be checked back
into the repo for use by others. The `test-*.sh` script and the `cfg-*.sh` scripts should simply contain environment variables that control how `workflow.sh`
and `workflow.swift` operate.

`test-1.sh` and `cfg-{sys,prm}-1.sh` should be unmodified for simple testing.

The relevant parameters for the GA algorithm are defined in `cfg-prm-*.sh` scripts (see example in `cfg-prm-1.sh`). These are:

- SEED: The random seed used by deap in the GA.
- NUM_ITERATIONS: The number of iterations the GA should perform.
- POPULATION_SIZE: The maximum number of hyperparameter sets to evaluate in each iteration.
- GA_STRATEGY: The algorithm used by the GA. Can be one of "simple" or "mu_plus_lambda".
- OFFSPRING_PROP: The offspring population size as a proportion of the population size (this is rounded) (specifically for the mu_plus_lambda strategy)
- MUT_PROB: Probability an individual is mutated.
- CX_PROB: Probability that mating happens in a selected pair.
- MUT_INDPB: Probability for each gene to be mutated in a mutated individual.
- CX_INDPB: Probability for each gene to be swapped in a selected pair.
- TOURNSIZE: Size of tournaments in selection process.

### Genetic Algorithm

The Genetic Algorithm is made to model evolution and natural selection by applying crossover (mating), mutation, and selection to a population in many iterations
(generations).

In the "simple" strategy, offspring are created with crossover AND mutation, and the selection for the next population happens from ONLY the offspring. In
the "mu_plus_lambda" strategy, offspring are created with crossover OR mutation, and the selection for the next population happens from BOTH the offpsring
and parent generation. Also in the mu_plus_lambda strategy, the number of offspring in each generation is a chosen parameter, which can be controlled by the
user through offspring_prop.

Mutation intakes two parameters: mut_prob and mut_indpb. The parameter mut_prob represents the probability that an individual will be mutated. Then, once an
individual is selected as mutated, mut_indpb is the probability that each gene is mutated. For example, if an individual is represented by the array
[11.4, 7.6, 8.1] where mut_prob=1 and mut_indpb=0.5, there's a 50 percent chance that 11.4 will be mutated, a 50 percent chance that 7.6 will be mutated,
and a 50 percent chance that 8.1 will be mutated. Also, if either of mut_prob or mut_indpb equal 0, no mutations will happen. The type of mutation we apply
depends on the data type because we want to preserve data type under mutation and 'closeness' may or may not represent similarity. For example, gaussian
mutation is rounded for integers to preserve their data type, and mutation is a random draw for categorical variables because being close in a list doesn't
equate to similarity.

Crossover intake two parameters: cx_prob and cx_indpb, which operate much in the same way as cx_prob and cx_indpb. For example, given two individuals
represented by the arrays [1, 2, 3] and [4, 5, 6] where cx_prob=1 and cx_indpb=0.5, there's a 50% chance that 1 and 4 will be 'crossed', a 50% chance that
2 and 5 will be 'crossed', and a 50% chance that 3 and 6 will be 'crossed'. Also, if either mut_prov or mut_indpb equal 0, no crossover will happen. The definition
of 'crossed' depends on the crossover function, which must be chosen carefully to protect data types. We use cx_Uniform, which swaps values such that [4, 2, 3],
[1, 5, 6] is a possible result from crossing the previously defined individuals. One example of a crossover function which doesn't preserve data types would be
cx_Blend, which averages values.

Selection has various customizations, with tournaments being our implementation. In tournament selection, 'tournsize' individuals are chosen, and the individual
with the best fitness score is selected. This repeats until the desired number of individuals are selected. Note that choosing individuals is done with replacement,
which introduces some randomness to who is selected. Although unlikely, it's possible for one individual to be the entire next population. It's also possible for
the best individual to not be selected as long as tournsize is smaller than the population. However, it is guaranteed that the worst 'tournsize-1' individuals are
not selected for the next generation. Tournsize can be thought of as the selection pressure on the population.

Notes:
- In the mu_plus_lambda strategy, cx_prob+mut_prob must be less than or equal to 1. This stems from how mutation OR crossover is applied in mu_plus_lambda, as
  opposed to mutation AND crossover in the simple strategy.
- GPUs can often sit waiting in most implementations of the Genetic Algorithm because the number of evaluations in each generation is usually variable. However,
  with a certain configuration, the number of evaluations per generation can be kept at a constant number of your choosing. By using mu_plus_lambda, the size
  of the offspring population is made through the chosen parameter of offspring_prop. Then, by choosing cx_prob and mut_prob such that cx_prob+mut_prob=1, every
  offspring is identified as a 'crossed' or mutated individual and evaluated. Hence, the number of evaluations in each generation equals lambda. Note that because
  of cx_indpb and mut_indpb, an individual may be evaluated with actually having different hyperparameters. This also means that by adjusting mut_indpb and cx_indpb,
  the level of mutation and crossover can be kept low despite cx_prob+mut_prob being high (if desired). Note that the number of evaluations per generation can be
  kept constant in the simple strategy as well, but the number of evals has to be the population size.
- Genetic Algorithms usually have mutation and crossover probabilites around 0.1. However, they also usually have population~500 and generations~100, which gives a lot
  of opportunity for mutation and crossover to happen. In the case of smaller populations and/or generations, it may be advantageous to increase mutation and crossover
  probabilites to larger than ordinary. In this case, the mu_plus_lambda strategy may be advantageous because of it's ability to select a parent for the next generation.
  Also, when there's a smaller number of generations (i.e. less number of times selection pressure is applied), it may be advantageous to increase tournament size (i.e.
  increase selection pressure strength) to compensate.
- The default values are: NUM_ITERATIONS=5  |  POPULATION_SIZE=16  |  GA_STRATEGY=mu_plus_lambda  |  OFFSPRING_PROP=0.5  |  MUT_PROB=0.8  |  CX_PROB=0.2  |
                          MUT_INDPB=0.5  |  CX_INDPB=0.5  |  TOURNSIZE=4

See https://deap.readthedocs.io/en/master/api/algo.html?highlight=eaSimple#module-deap.algorithms for more information.

### Hyperparameter Configuration File <a name="config"></a>###

The GA workflow uses a json format file for defining the hyperparameter space. The GA workflow comes with 4 sample hyperparameter spaces in the `GA/data` directory, one each for the combo, nt3, p1b1 and tc1 benchmarkts.

The hyperparameter configuration file has a json format consisting of a
list of json dictionaries, each one of which defines a hyperparameter. Each dictionary has the following required keys:

- name: the name of the hyperparameter (e.g. _epochs_)
- type: determines how the initial population (i.e. the hyperparameter sets) are initialized from the named parameter and how those values are subsequently mutated by the GA. Type is one of `constant`, `int`, `float`, `logical`, `categorical`, or `ordered`.
  - `constant`:
    - each model is initialized with the same specifed value
    - mutation always returns the same specified value
  - `int`:
    - each model is initialized with an int randomly drawn from the range defined by `lower` and `upper` bounds
    - mutation is peformed by adding the results of a random draw from
      a gaussian distribution to the current value, where the gaussian distribution's mu is 0 and its sigma is specified by the `sigma` entry.
  - `float`:
    - each model is initialized with a float randomly drawn from the range defined by `lower` and `upper` bounds
    - mutation is peformed by adding the results of a random draw from
      a gaussian distribution to the current value, where the gaussian distribution's mu is 0 and its sigma is specified by the `sigma` entry.
  - `logical`:
    - each model is initialized with a random boolean.
    - mutation flips the logical value
  - `categorical`:
    - each model is initialized with an element chosen at random from the list of elements in `values`.
    - mutation chooses an element from the `values` list at random
  - `ordered`:
    - each model is inititalized with an element chosen at random from the list of elements in `values`.
    - given the index of the current value in the list of `values`, mutation selects the element _n_ number of indices away, where n is the result of a random draw between 1 and `sigma` and then is negated with a 0.5 probability.

The following keys are required depending on value of the `type` key.

If the `type` is `constant`:

- `value`: the constant value

If the `type` is `int`, or `float`:

- `lower`: the lower bound of the range to draw from
- `upper`: the upper bound of the range to draw from
- `sigma`: the sigma value used by the mutation operator (see above).

If the `type` is `categorical`:

- `values`: the list of elements to choose from
- `element_type`: the type of the elements to choose from. One of `int`, `float`, `string`, or `logical`

If the `type` is `ordered`:

- `values`: the list of elements to choose from
- `element_type`: the type of the elements to choose from. One of `int`, `float`, `string`, or `logical`
- `sigma`: the sigma value used by the mutation operator (see above).

A sample hyperparameter definition file:

```javascript
[
  {
    name: "activation",
    type: "categorical",
    element_type: "string",
    values: [
      "softmax",
      "elu",
      "softplus",
      "softsign",
      "relu",
      "tanh",
      "sigmoid",
      "hard_sigmoid",
      "linear",
    ],
  },

  {
    name: "optimizer",
    type: "categorical",
    element_type: "string",
    values: ["adam", "rmsprop"],
  },

  {
    name: "lr",
    type: "float",
    lower: 0.0001,
    upper: 0.01,
    sigma: "0.000495",
  },

  {
    name: "batch_size",
    type: "ordered",
    element_type: "int",
    values: [16, 32, 64, 128, 256],
    sigma: 1,
  },
];
```

Note that any other keys are ignored by the workflow but can be used to add additional information about the hyperparameter. For example, the sample files
contain a `comment` entry that contains additional information about that hyperparameter.

### Where to check for output

This includes error output.

When you run the test script, you will get a message about `TURBINE_OUTPUT` . This will be the main output directory for your run.

- On a local system, stdout/stderr for the workflow will go to your terminal.
- On a scheduled system, stdout/stderr for the workflow will go to `TURBINE_OUTPUT/output.txt`

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
