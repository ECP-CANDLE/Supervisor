#!/usr/bin/env python

"""
HPO TABLE

Extract a CSV table from HPO results model.logs
Input:  A directory containing run_* directories from the GA workflow
Output: A CSV file containing run statistics
"""


hyperparameters = [ "learning_rate", "dropout" ]
hyperparameters.sort()


def main():
    args = parse_args()
    model_runs = find_runs(args.experiment_directory)
    # A list of dict.  The dict contains the stats for the run
    table = []
    for run in model_runs:
        add_stats(run, table)
    write_table(table, args.output_csv)


def parse_args():
    import argparse
    parser = argparse.ArgumentParser(prog="HPO Table")
    parser.add_argument("experiment_directory")
    parser.add_argument("output_csv")
    args = parser.parse_args()
    return args


def crash(message):
    print("hpo_table: ERROR: " + message)
    exit(1)

def find_runs(experiment_directory):
    import glob
    L = glob.glob(experiment_directory + "/run*")
    if len(L) == 0:
        crash("Found 0 run directories!")
    return L


def add_stats(run, table):
    values = {}
    model_log = run + "/model.log"
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


def write_table(table, output_csv):
    import csv
    # Create the header
    row = []
    row += ["run"]
    row += hyperparameters
    row += ["walltime", "metric", "result"]
    with open(output_csv, "w") as fp:
        writer = csv.writer(fp, delimiter=",")
        # Write the header
        writer.writerow(row)
        for values in table:
            row.clear()
            row.append(values["run_id"])
            for hp in hyperparameters:
                row.append(values[hp])
            row.append(0)
            row.append(values["metric"])
            row.append(values["result"])
            writer.writerow(row)


main()
