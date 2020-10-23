# Simple grid or random parameter sweep with Swift for all the benchmarks, using command line. D type , which runs a parameter sweep. It calls command-line programs as follows:
- determineParameters.{sh,py}: Reads data/**settings.json** for sweep parameters, and return as a string for use by Swift program (sweep-parameters.txt)
- evaluateOne.{sh,py}: Runs a single experiment. (Calls the specified benchmark).
- computeStats.{sh,py}: Ingests data from all of the experiments and computes simple stats.

Usage: ./run <run directory> <benchmark name> <search type> ./run ex3_p1b1_grid p1b1 grid

Notes:
**settings.json**: sweep parameters variation
1. json file must be present in the data folder and named as: <benchmark name>_settings.json, samples files are available and must be modified as per needs.
2. Run directory will be created in the experiments folder
3. New variables can be introduced in the determineParameters.py and evaluateOne.py. 
4. Variations of parameters must be specified in data/*.json files
