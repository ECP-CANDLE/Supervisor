#!/usr/bin/env python

"""
HPO TABLE

Extract a CSV table from HPO results model.logs
Input:  A directory containing run_* directories from the GA workflow
Output: A CSV file containing run statistics
"""

import logging, os, sys


def main():
    logger = get_logger(None, "hpo_table")
    args = parse_args(logger)
    handle_args(logger, args)
    args.hyperparameter.sort()
    model_runs = find_runs(logger, args.experiment_directory)
    # A list of dict.  The dict contains the stats for the run
    table = []
    for run in model_runs:
        add_stats(logger, args.hyperparameter, run, table)
    write_table(logger, args.hyperparameter, table, args.output_csv)


def get_logger(logger, name, stream=sys.stdout):
    """
    Set up logging if necessary
    If the caller's logger already exists, just return it.
    """
    if logger is not None:
        return logger
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)
    h = logging.StreamHandler(stream=stream)
    fmtr = logging.Formatter(
        "%(asctime)s %(name)s %(levelname)-5s %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S")
    h.setFormatter(fmtr)
    logger.addHandler(h)
    return logger


def parse_args(logger):
    import argparse
    parser = argparse.ArgumentParser(prog="HPO Table")
    parser.add_argument("experiment_directory")
    parser.add_argument("output_csv")
    parser.add_argument("-p", "--hyperparameter", action="append")
    parser.add_argument("-v", "--verbose", action="store_true")
    args = parser.parse_args()
    return args


def crash(message):
    print("hpo_table: ERROR: " + message)
    exit(1)


def handle_args(logger, args):
    if args.verbose:
        logger.setLevel(logging.DEBUG)
    logger.debug(str(args))


def find_runs(logger, experiment_directory):
    import glob
    if not os.path.exists(experiment_directory):
        crash("Experiment directory does not exist: '%s'" %
              experiment_directory)
    L = glob.glob(experiment_directory + "/run_*")
    if len(L) == 0:
        crash("Found 0 run directories!")
    logger.debug("Found %i run directories..." % len(L))
    L.sort()  # Optional: puts resulting CSV in order
    return L


def add_stats(logger, hyperparameters, run, table):
    values = {}
    model_log = run + "/model.log"
    if not os.path.exists(model_log):
        crash("Model log does not exist: '%s'" % model_log)
    with open(model_log, "r") as fp:
        while True:
            line = fp.readline()
            # Try until we find something:
            if len(line) == 0: break
            tokens = line.split()
            if len(tokens) < 2: continue
            prefix = tokens[0]
            if prefix == "IMPROVE_RESULT":
                values["metric"] = tokens[1][:-1]
                values["result"] = tokens[2]
                continue
            for hp in hyperparameters:
                if prefix == hp:
                    values[hp] = tokens[1]
                    break
            if len(tokens) < 4: continue
            if tokens[3] == "RUNID:":
                values["run_id"] = tokens[4][4:]
                continue
    table.append(values)


def write_table(logger, hyperparameters, table, output_csv):
    import csv
    # Create the header
    row = []
    row += ["iteration", "sample"]
    row += hyperparameters
    row += ["walltime", "metric", "result"]
    logger.debug("writing: " + output_csv)
    with open(output_csv, "w") as fp:
        writer = csv.writer(fp, delimiter=",")
        # Write the header
        writer.writerow(row)
        for values in table:
            row.clear()
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
            writer.writerow(row)
    logger.debug("wrote: " + output_csv)


main()
