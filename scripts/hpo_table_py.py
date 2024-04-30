#!/usr/bin/env python

"""
HPO TABLE PY PY

For plain Python runs
Extract a CSV table from HPO results out-*.txt
Input:  A directory containing out-*.txt files the GA workflow
Output: A CSV file containing run statistics
"""

import logging, os, sys
from hpo_table_utils import crash, get_logger, parse_time


LOGGING_TRACE = 5


def main():
    logger = get_logger(None, "hpo_table")
    args = parse_args(logger)
    handle_args(logger, args)
    args.hyperparameter.sort()
    model_outs = find_outs(logger, args.experiment_directory)
    # A list of dict.  The dict contains the stats for the run
    table = []
    for run in model_outs:
        add_stats(logger, args.hyperparameter, run, table)
    write_table(logger, args.hyperparameter, table, args.output_csv)


def parse_args(logger):
    import argparse
    parser = argparse.ArgumentParser(prog="HPO Table")
    parser.add_argument("experiment_directory")
    parser.add_argument("output_csv")
    parser.add_argument("-p", "--hyperparameter", action="append", default=[],
                        help="may be provided multiple times or " +
                        "comma-separated")
    parser.add_argument("-v", "--verbose", action="store_true")
    args = parser.parse_args()
    return args


def handle_args(logger, args):
    global LOGGING_TRACE
    if args.verbose:
        logger.setLevel(logging.DEBUG)
    logger.log(level=LOGGING_TRACE, msg="args: " + str(args))
    # Split up any comma-separated hyperparameters:
    delete = []
    for hp in args.hyperparameter:
        if "," in hp:
            delete.append(hp)
            tokens = hp.split(",")
            for token in tokens:
                args.hyperparameter.append(token)
    for d in delete:
        args.hyperparameter.remove(d)
    logger.debug("hyperparameters: " + str(args.hyperparameter))


def find_outs(logger, experiment_directory):
    import glob
    if not os.path.exists(experiment_directory):
        crash("Experiment directory does not exist: '%s'" %
              experiment_directory)
    L = glob.glob(experiment_directory + "/out/out-*.txt")
    if len(L) == 0:
        crash("Found 0 output files!")
    logger.debug("Found %i run output files..." % len(L))
    L.sort()  # Optional: puts resulting CSV in order
    return L


def add_stats(logger, hyperparameters, output_file, table):
    """
    Note that the token length checks increase monotonically
    """
    values = {}
    logger.debug("Open: '%s' ..." % output_file)
    with open(output_file, "r") as fp:
        while True:
            line = fp.readline()
            # Try until we find something:
            if len(line) == 0: break
            tokens = line.split()
            if len(tokens) < 3: continue
            # E.g. "IMPROVE_RESULT val_loss:        0.05259979888796806"
            if len(tokens) == 3 and tokens[0] == "IMPROVE_RESULT":
                print("line: " + line)
                values["metric"] = tokens[1][:-1]
                values["result"] = tokens[2]
                continue
            if line.startswith("ADLB Total Elapsed Time:"):
                logger.debug("\t This is a server.")
                # This is a server rank - no data
                return
            if len(tokens) < 6: continue
            if tokens[2] == "DEAP":
                logger.debug("\t This is DEAP.")
                # This is a DEAP - no data
                return
            # E.g. "2024-04-27 20:15:45 MODEL RUNNER DEBUG run_id = run_01_001_0026"
            if tokens[5] == "run_id":
                values["run_id"] = tokens[7][4:]
                continue
            if len(tokens) < 7: continue
            # E.g. "2024-04-27 20:11:57 MODEL RUNNER DEBUG run(): START:"
            if tokens[6] == "START":
                values["start"] = parse_time(tokens[0], tokens[1])
            if len(tokens) < 8: continue
            # E.g. "2024-04-27 20:52:23 MODEL RUNNER INFO  PKG RUN STOP"
            if tokens[7] == "STOP":
                values["stop"] = parse_time(tokens[0], tokens[1])
            # E.g. "2024-04-27 20:17:06 MODEL RUNNER DEBUG batch_size = 16"
            label = tokens[5]
            for hp in hyperparameters:
                if label == hp:
                    values[hp] = tokens[7]
                    break
    validate(logger, output_file, values)
    # Insert output_file for debugging
    values["output_file"] = output_file
    table.append(values)


def validate(logger, output_file, values):
    required = ["metric", "result", "run_id", "start", "stop"]
    for key in required:
        if key not in values:
            logger.fatal("missing key: '%s'"  % key)
            logger.fatal("output file: " + output_file)
            exit(1)


def write_table(logger, hyperparameters, table, output_csv):
    import csv
    global LOGGING_TRACE
    # Create the header
    row = []
    row += ["iteration", "sample"]
    row += hyperparameters
    row += ["metric", "result", "walltime"]
    logger.log(level=LOGGING_TRACE, msg="writing: " + output_csv)
    with open(output_csv, "w") as fp:
        writer = csv.writer(fp, delimiter=",")
        # Write the header
        writer.writerow(row)
        for values in table:
            row.clear()
            print(str(values))
            tokens = values["run_id"].split("_")
            iteration, sample = tokens[1:3]
            row += [iteration, sample]
            for hp in hyperparameters:
                try:
                    row.append(values[hp])
                except:
                    crash("missing hyperparameter '%s' in run %s" %
                          (hp, values["run_id"]))
            row.append(0)
            row.append(values["metric"])
            row.append(values["result"])
            td = values["stop"] - values["start"]  # a timedelta
            row.append(int(td.total_seconds()))
            writer.writerow(row)
    logger.debug("wrote:   " + output_csv)


main()
