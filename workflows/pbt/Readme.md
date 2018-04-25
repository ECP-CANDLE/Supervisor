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
example workflow (`python/tc1_pbt.py`). This example workflow trains a variant of our TC1 benchmark. A model is considered underperforming if its validation
loss is in the lower 20% of the population, at which time it will perform an
exploit and explore. During exploit a model loads the weights of a model
randomly selected from the top 20%. (Loading and storing of weights is
file-based, where weights are serialized every epoch and then loaded as
necessary.) During the explore, a model perturbs the learning rate of the
selected better performing model, and then continues training with the new
weights and learning rate.

## Requirements ##

## Directory Structure ##

## Running the Example ##

## Extending the Example ##
