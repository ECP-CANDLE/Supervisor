#!/usr/bin/env python

"""
HPO TABLE CONTAINER

For Singularity container runs
Extract a CSV table from HPO results model.logs
Input:  A directory containing run_* directories from the GA workflow
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
    model_runs = find_runs(logger, args.experiment_directory)
    # A list of dict.  The dict contains the stats for the run
    table = []
    for run in model_runs:
        add_stats(logger, args.hyperparameter, run, table)
    write_table(logger, args.hyperparameter, table, args.output_csv)


def parse_args(logger):
    import argparse
    parser = argparse.ArgumentParser(prog="HPO Table")
    parser.add_argument("experiment_directory")
    parser.add_argument("output_csv")
    parser.add_argument("-p", "--hyperparameter", action="append",
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
        values["result"] = None
        while True:
            line = fp.readline()
            # Try until we find something:
            if len(line) == 0: break
            tokens = line.split()
            if len(tokens) < 2: continue
            # Find only the first IMPROVE_RESULT in the file
            if values["result"] is None:
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
            if tokens[3] == "START":
                values["start"] = parse_time(tokens[0], tokens[1])
            if tokens[3] == "END:":
                values["stop"] = parse_time(tokens[0], tokens[1])
            if tokens[3] == "RUNID:":
                values["run_id"] = tokens[4][4:]
                continue
    table.append(values)


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
