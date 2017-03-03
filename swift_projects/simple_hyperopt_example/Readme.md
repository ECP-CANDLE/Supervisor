# Simple Example of EMEWS Integration with hyperopt #

This directory contains a simple example of integrating hyperopt with
EMEWS.

Requirements:

* Python 3 (for now)
* hyperopt : (http://hyperopt.github.io/hyperopt/). Install with
`pip install hyperopt`
* Swift/T with python extension

Run the example with `swift/simple_workflow.sh`. That should properly set the
PYTHONPATH, but it does assume that swift-t is in your PATH already.

The workflow attempts to minimize the function sin(x) over a range of -2 to 2
using hyperopt's `hyperopt.rand.suggest` search algorithm. It also works with
hyperopt's tpe.suggest, but there's less parallelism to exploit there. The
actual 'model' that computes sin(x) is this python code:

```
import math

params = %s
a = math.sin(params['x'][0])
```

Hyperopt formats the model / function parameters it produces as python
dictionaries. Using string templating, the %s in the above python code
is replaced with the literal representation of that dictionary. For example,

```
import math

params = {'x': [-1.5477895914281512]}
a = math.sin(params['x'][0])
```

That code is then executed using swift's python call, and the result
returned back to hyperopt via the eqpy_hyperopt package.

The workflow:

1. Initialize the eqpy_hyperopt python with the hyperopt algorithm parameters.
These are formated as a string representation of a python dictionary.
```
{'space' : %s,
'algo' : %s,
'max_evals' : %d,
'param_batch_size' : %d,
'seed' : %d}
```
These are explained in the Readme for eqpy_hyperopt in this repository.

2. Request a list of parameter sets from hyperopt. The list is a ";" separated
string of python dictionaries. For example,
```
{'x': [-1.5477895914281512]};{'x': [1.23432434]};{'x': [0.32343]}
```
If there were more parameters in addition to 'x', those would appear in the
dictionary as well.

3. Split the list of parameters into an array and execute the model on
each element in that array in parallel. As explained above, executing the model consists
of pasting in the parameters in the python 'model' code and executing that
with a swift python call.

4. Repeat 2 and 3 until the maximum number of evaluations has been reached
(`max_evals`).

5. Print and write out the best parameter set found by hyperopt.
