# EQPy-enabled Hyperopt

Files:

- eqpy_hyperopt/ - eqpy_hyperopt python package
- tests/ - unit tests for eqpy_hyperopt

eqpy_hyperopt/hyperopt_runner.py contains code that integrates hyperopt with
a swift script via eqpy get and put calls.

Initialize eqpy_hyperopt from swift with

```
EQPy_init_package(ME,"eqpy_hyperopt.hyperopt_runner")
```

On initialization eqpy_hyperopt will put an empty string in the output
queue as handshake for swift to receive. Swift should then send a string
containing the hyperopt parameters. This string should be formatted as a
python dictionary. For example,

```
{
 'space' : hyperopt.hp.uniform(\'x\', -2, 2),
 'algo' : hyperopt.rand.suggest,
 'max_evals' : 100,
 'param_batch_size' : 10
}
```

The elements of the dictionary are:

- space : see https://github.com/hyperopt/hyperopt/wiki/FMin#2-defining-a-search-space
  The set of possible arguments to the model.

- algo : search algorithm
  This object, such as `hyperopt.rand.suggest` and
  `hyperopt.tpe.suggest` provides logic for sequential search of the
  hyperparameter space.

- max_evals : int
  Allow up to this many function evaluations before returning.

- param_batch_size : int
  Retrieve at most this many new parameters sets from the search
  algorithm for evaluation up to max_evals. Note that the actual
  number of new parameter sets to evaluate is dependent on the
  search algorithm.

Once these are received eqpy_hyperopt will initialize hyperopt and put the
first of set (up to `param_batch_size`) in size in the output queue for swift
to retreive. It then waits for swift to return the result of evaluating the
model with these parameters.

The evaluation results should be returned as a "," separated string where
is element is a single number. For example,

```
-1.23434,0.42422,-0.0001
```

The order of the results in the results string should match the order of the
parameters (i.e. the first number in the results string is the result of the
first model evaluation).

When the `max_evals` number of evaluations has occurred, eqpy_hyperopt will
put "FINAL" in the output queue, and then put the best parameters in the
output queue.

## Tests

The tests test basic eqpy_hyperopt functionality by running it 'stand-alone'
without any eqpy mediated interation and also using eqpy but in a pure python
context.

Run the unit tests from within the tests directory with

`python -m unittest test_hyperopt`

Source settings.sh to set the PYTHONPATH correctly.

## Misc

Pymongo / BSON were causing issues on Cori so that's "monkey patched" by setting `hyperopt.base.have_bson = False`.
