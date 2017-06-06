# Simple parameter sweep with Swift, using command line programs
**run** runs **run-sweep.swift**, which runs a parameter sweep. It calls command-line programs as follows:
- determineParameters.{sh,py}: Read data/ **settings.json** for sweep parameters, and return as a string for use by Swift program
- evaluateOne.{sh,py}: Runs a single experiment. (Calls p1b1_baseline).
- computeStats.{sh,py}: Ingests data from all of the experiments and computes simple stats.

Usage: ./run 

Notes:
- **settings.json**: sweep parameters. Parameters must be labeled "1", "2", "3", "4", ... 
1: epochs
2. batch_size
3. N1
4. NE