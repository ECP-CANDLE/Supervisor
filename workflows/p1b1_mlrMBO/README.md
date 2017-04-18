# P1B1 mlrMBO Workflow #

The P1B1 mlrMBO workflow evaluates a modified version of the P1B1 benchmark
autoencoder using hyperparameters provided by a mlrMBO instance. The P1B1
code (p1b1_baseline.py) has been modified to expose a functional interface.
The neural net remains the same. Currently, mlrMBO minimizes the validation
loss.

Requirements:

* Python 2.7
* P1B1 Autoencoder - git@github.com:ECP-CANDLE/Benchmarks.git. Clone and switch
to the supervisor branch.
* P1B1 Data - `http://ftp.mcs.anl.gov/pub/candle/public/benchmarks/P1B1/P1B1.train.csv` and `http://ftp.mcs.anl.gov/pub/candle/public/benchmarks/P1B1/P1B1.test.csv`. Download these into some suitable directory (e.g. `workflows/p1b1_hyperopt/data`)
* mlrMBO - https://mlr-org.github.io/mlrMBO/
* Keras - https://keras.io. The supervisor branch of P1B1 should work with
both version 1 and 2.
* Swift-t with Python 2.7 and R enabled - http://swift-lang.org/Swift-T/
