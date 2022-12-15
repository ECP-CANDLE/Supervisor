# Simple parameter sweep with Swift -> parameters randomly chosen between specified bounds.

The main program (random-sweep.swift) calls a few app functions as follows:

- determineParameters.{sh,py}: Read data/ **settings.json** for sweep parameters, and return as a string for use by Swift program
- evaluateOne.{sh,py}: Runs a single experiment. (Calls p1b1_runner).
- computeStats.{sh,py}: Ingests data from all of the experiments and computes simple stats.

Usage: ./run experient_1

Notes:

- **settings.json**:
  A. parameters (benchmark parameters)
  =====================================
  1: epochs

2. batch_size
3. N1
4. NE

# B. samples (specifies the number of random samples to prepare)

1. num

For adding new parameters:

1. Add to the json file the desired parameters
2. Read params in determineParameters.py: def loadSettings(settingsFilename):
3. Modify the evaluateOne.py file (set to run on keras framework now)
