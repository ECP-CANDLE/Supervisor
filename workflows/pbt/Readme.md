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
setting the queue, walltime, python, etc. for your HPC machine. Its currently configured for NERSC's Cori system.

### Hyperparameter Configuration File ###

The PBT workflow uses a json format file for defining the hyperparameter space used by the PBT algorithm. The PBT workflow includes 2 sample hyperparameter
configuration files for the tc1 model.

* `data/tc1_params_full.json`: runs the full tc1 model, including the default convoluation layer and no feature subsampling.
* `data/tc1_params_small.json`: runs a faster version of the tc1 model by ommitting the convolution layer and subsampling the features.

The hyperparameter configuration file has a json format consisting of a
list of json dictionaries, each one of which defines a hyperparameter. Each map
has the following required entries:

* name:
* type:
* element_type:
* values:

Any other entry are ignored by the workflow but can be used to add additional information about the hyperparameter. For example, the sample files contain a
`comment` entry that contains additional information about that hyperparameter.




## Workflow Explained ##


## Adapting the Workflow ##
Writing your own ready exploit explore

## Repository Notes ##
