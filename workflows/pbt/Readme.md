# PBT #

PBT is an asynchronous optimization algorithm for jointly optimizing a
population of models and their hyperparameters while effectively using a fixed
computational budget. Like a simple parallel grid
search, PBT begins by randomly sampling selected hyperparameters and initial
weights and training multiple models in parallel using these hyperparameters and
weights. However, unlike a parallel search, each training run periodically and
asynchronously runs an evaluate method, comparing its performance against that
of other models. If it is under-performing, PBT uses two additional methods to
improve performance: exploit and explore. Exploit leverages the work of the
population as a whole by replacing an underperforming model with a better one,
i.e., by replacing a model’s current weights with those of the better performing
model.  Explore attempts to find new better performing hyperparameters by
perturbing those of the better performing model. Training then continues with
the new weights and the new hyperparameters. Evaluate, exploit, and explore are
performed asynchronously and independently by each model for some specified
number of steps. In this way the hyperparameters are optimized online and
computational resources are focused on better performing hyperparameters and
weights, quickly discarding unpromising solutions.

This PBT example is written in Python using the MPI for Python (mpi4py) package.
It consists of model agnostic framework code for creating PBT workflows (`python/pbt.py`) and an
example workflow (`python/tc1_pbt.py`). This example workflow trains a variant of our tc1 benchmark (`models/tc1`). In this example, a tc1 model run is considered underperforming if its validation
loss is in the lower 20% of the population, at which time it will perform an
exploit and explore. During exploit a model loads the weights of a model
randomly selected from the top 20%. (Loading and storing of weights is
file-based, where weights are serialized every epoch and then loaded as
necessary.) During the explore, a model perturbs the learning rate of the
selected better performing model, and then continues training with the new
weights and learning rate.

## Requirements ##

* This workflow: git@github.com:ECP-CANDLE/Supervisor.git. Clone and cd to workflows/pbt (the directory containing this README).

* Python: the PBT workflow has been tested under Python 2.7.

* MPI for Python (mpi4py): http://mpi4py.scipy.org/docs/

* Keras: https://keras.io

* CANDLE Benchmark Code: git@github.com:ECP-CANDLE/Benchmarks.git. Clone and switch to the frameworks branch.

* TC1 benchmark data:
    ```
  ftp://ftp.mcs.anl.gov/pub/candle/public/benchmarks/Pilot1/type-class/type_18_300_test.csv
  ftp://ftp.mcs.anl.gov/pub/candle/public/benchmarks/Pilot1/type-class/type_18_300_train.csv
    ```

    `type_18_300_train.csv` and `type_18_300_test.csv` should be copied into `X/Benchmarks/Data/Pilot1`, where X is wherever you cloned the Benchmark repository. For example, from within X/Benchmarks

  ```
  mkdir -p Data/Pilot1
  cd Data/Pilot1
  wget ftp://ftp.mcs.anl.gov/pub/candle/public/benchmarks/Pilot1/type-class/type_18_300_test.csv
  wget ftp://ftp.mcs.anl.gov/pub/candle/public/benchmarks/Pilot1/type-class/type_18_300_train.csv
  ```


## Running the Workflow ##
The PBT workflow is an MPI application that given N number of processes, runs N - 1 tc1 models, and uses the remaining process to run a datastore into which the models can put and get model peformance data. The workflow can be run using the scripts in the `scripts` directory. Two scripts provided: `local_run_pbt.sh` and
`sbatch_run_pbt.sh`. The former can be used to run on a local desktop or
laptop. The latter can be used to submit the PBT workflow on hpc resources
that use the slurm scheduler. In either case, main application file is `python/tc1_pbt.py`.

When run the PBT workflow will create an experiments directory in which the output will be written. The output consists of a `weights` directory into which
each tc1 instance writes is model weights every epoch, and an output.csv file
that records the accuracy, loss, learning rate, validation accuracy, and validation loss for each model (identified by MPI rank) each epoch. Additionally each tc1 model run will execute within its own `run_N` instance directory (e.g. `run_1`, `run_2` and so forth).

### local_run_pbt.sh ###

 `local_run_pbt.sh` takes 3 arguments

1. The number of processes to use
2. An experiment id
3. The path to a pbt parameter file (see below) that defines the tc1 hyperparameters

The experiment id is used to as the name of the experiments directory into which the model output will be written as mentioned above. For example, given the location of the `scripts` directory as `workflows/pbt/scripts` and an
experiment id of `r1`, the experiments directory will be `workflows/pbt/experiments/r1`.

### sbatch_run_pbt.sh ###

`sbatch_run_pbt.sh` takes 2 arguments:

1. An experiment id
2. The path to a pbt parameter file (see below) that defines the tc1 hyperparameters

The experiment id is again used to as the name of the experiments directory into which the model output will be written as mentioned above. For example, given the location of the `scripts` directory as `workflows/pbt/scripts` and an
experiment id of `r1`, the experiments directory will be `workflows/pbt/experiments/r1`.

`sbatch_run_pbt.sh` ultimately calls `sbatch` to submit the job defined in
`scripts/pbt.sbatch`. That file can be copied and or edited as appropriate,
setting the queue, walltime, python, etc. for your HPC machine. It is currently configured for NERSC's Cori system.

### Hyperparameter Configuration File ###

The PBT workflow uses a json format file for defining the hyperparameter space used by the PBT algorithm. The PBT workflow includes 2 sample hyperparameter
configuration files for the tc1 model.

* `data/tc1_params_full.json`: runs the full tc1 model, including the default convoluation layer and no feature subsampling.
* `data/tc1_params_small.json`: runs a faster version of the tc1 model by ommitting the convolution layer and subsampling the features.

The hyperparameter configuration file has a json format consisting of a
list of json dictionaries, each one of which defines a hyperparameter. Each dictionary has the following required keys:

* name: the name of the hyperparameter (e.g. epochs)
* type: determines how the models are initialized from the named parameter - one of `constant`, `int`, `float`, `logical`, or `categorical`.
  * `constant`: all the tc1 models are initialized with the specifed value
  * `int`: each tc1 model is initialized with an int randomly drawn from the range defined by `lower` and `upper` bounds
  * `float`: each tc1 model is initialized with a float randomly drawn from the range defined by `lower` and `upper` bounds
  * `logical`: each tc1 model is initialized with a random boolean.
  * `categorical`: each tc1 model is initialized with an element chosen at random from the list of values in `values`.

The following keys are required depending on value of the `type` key.

If the `type` is `constant`:
  * `value`: the constant value

If the `type` is `int`, or `float`:
  * `lower`: the lower bound of the range to randomly draw from
  * `upper`: the upper bound of the range to randomly draw from

If the `type` is `categorical`:
  * `values`: the list of elements to randomly choose from
  * `element_type`: the type of the elements to choose from. One of `int`, `float`, `string`, or `logical`

A sample hyperparameter definition file:

```javascript
[
  {
    "name": "epochs",
    "type": "constant",
    "value": 5
  },

  {
    "name": "activation",
    "type": "categorical",
    "element_type": "string",
    "values": ["softmax", "elu", "softplus", "softsign", "relu", "tanh", "sigmoid", "hard_sigmoid", "linear"]
  },

  {
    "name": "batch_size",
    "type": "categorical",
    "element_type": "int",
    "values": [32, 64]
  },

  {
    "name": "lr",
    "type": "float",
    "lower": 0.0001,
    "upper": 0.01
  }
]
```

Note that any other keys are ignored by the workflow but can be used to add additional information about the hyperparameter. For example, the sample files
contain a `comment` entry that contains additional information about that hyperparameter.


## Workflow Explained ##

The workflow consists of 3 parts. The DNN tc1 model in `models/tc1`, the PBT python code in `python/pbt.py` and the python code that runs the tc1 model
using PBT (`python/tc1_pbt.py`).

### tc1 ###

The tc1 model is a lightly modeified version of the CANDLE tc1 benchmark. The
code has been updated so that an external Keras callback can be passed
through `models/tc1/tc1_runner.run()` and attached to the model. The PBT
algorithnm is run via this callback.

### `python/pbt.py` ###

`pbt.py` provides the model-agnostic framework code for implementing a PBT workflow. It has 3 main components.

1. A PBTMetaDataStore class. This implements an in-memory datastore for the model run performance and hyperparamter metadata. It also manages a locking scheme for model weight file IO, in order to prevent issues with concurrent
file access.

2. A PBTClient class. This allows an individual instance of a model to communicate with the PBTMetaDataStore, sending it peformance metadata, querying
performance metadata for a better performing model, requesting read and write locks for reading other model weights and writing its own. The PBTClient and
PBTMetaDataStore communicate via MPI.

3. A PBTCallback class. This is a Keras callback that given model-specific
*ready*, *exploit*, and *explore* implementations will pass its current performance data to the data store and write its model's weights
every epoch. Then when *ready* it will get a better performing model (assuming there is one), and using *exploit* and *explore* it will updates its model's weights and hyperparameters appropriately. A PBTCallback uses a PBTClient to
communicate with a PBTMetaDataStore.

### `python/tc1_pbt.py` ###

`tc1_pbt.py` implements PBT for the tc1 model using the classes and functions in `pbt.py`. In `tc1_pbt.py`, rank 0 first generates and distribute the hyperparameters to the models running on the other ranks. The ga_utils package
is used to read the hyperparameter configuration file and generate a random value for the appropriate hyperparameters. Once the hyperparameters are
distributed, a PBTMetaDataStore is started, also on rank 0.

PBTMetaDataStore's
constructor is passed the path of the output directory where the `output.csv`
file will be written together with a the path to a log file in which user
customizable log messages are written. PBTMetaDataStore also takes a reference
to a *selection* function that is used to select a better performing model. That function
must have the following arguments: a list of dictionaries that contains the metadata for all the models, and a *score* against which model performance is determined. Exactly what the score represents (e.g. the validation loss) is
domain specific and is provided in the `PBTWorker.pack_data` method described
below.

In `tc1_pbt.py`, the `truncation_select` function implements this API is passed to the PBTMetaDataStore. In `truncation_select`, if the specified score is in the top 80% of scores, then an empty dictionary is returned. This empty dictionary indicates that a better performing model was not selected and thus
*exploit* and *explore* should not occur. If the specified score is in the bottom 20% then the metadata for a model in the top 20% is random selected
and returned in a python dictionary. The data in this dictionary including
then rank of the better performing model and its relevant hyperparameters can then be used in *exploit* and *explore*.

With the PBTMetaDataStore initialized on rank 0, all the remaining processes
run the tc1 model. A PBTCallback is added to each one of these models. The
PBTCallback constructor requires a class that implements the PBTWorker interface. A PBTCallback calls the 3 methods of a PBTWorkder to:

1. Retrieve a model's metadata and hyperparameters in order put them in the
PBTMetaDataStore (`PBTWorker.pack_data`),
2. Specifies which performance metric to use as the 'score' for model performance (also in `PBTWorker.pack_data`).
3. Determine when a model is ready for a potential exploit and explore (`PBTWorker.ready`),
4. Perform the exploit and explore update (`PBTWorker.update`).

In the tc1 PBT workflow, `tc1_pbt.TC1PBTWorker` implements the `PBTWorker`
interface. `TC1PBTWorker.pack_data` retrieves a model's current learning rate, and specifies the validation loss as the performance score. `TC1PBTWorker.ready` specifies that the model is *ready* every 5 epochs. `TC1PBTWorker.update` updates the model with a better performing learning rate after having perturbed it. Note that `update` does not need to load the better performing model's weights. That is done automatically in PBTCallback.

In sum then, in a PBTCallback at the end of every epoch:

1. `pack_data` is called to store every model's performance metadata and selected hyperparameters to the PBTMetaDataStore.
2. `ready` is called to determine if model is ready for a potential exploit / explore update.
3. If `ready` returns true, then the PBTCallback queries the PBTMetaDataStore for a better performing model using the selection function (e.g. `truncation_select`).
4. If the selection function returns data from a better performing model, then
`update` is called to update the model with the better performing data and the
better performing model's weights are loaded into the poorer performing model.

## Adapting the Workflow to a Different Model ##

`tc1_pbt.py` can easily be adapted to work with a different model. The following changes will need to be made:

* A new hyperparameter definition file. The rank 0
code that reads this file can be re-used.

* A new *selection* function. This can be passed to the PBTMetaDataStore
constructor in place of the tc1 one.

* A new PBTWorker implementation, implementing `ready`, `pack_data`, and
`update` as appropriate for the new model and workflow. This can be
passed to the PBTCallback in place of the existing tc1 one.
