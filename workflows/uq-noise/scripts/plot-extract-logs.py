#!/usr/bin/env python

import argparse
import os
import sys
from pprint import pprint

parser = argparse.ArgumentParser()
parser.add_argument("output",
                    help="The workflow output directory " +
                    "(input to this script)")
parser.add_argument(
    "obj_return",
    help="The key to look for in the model.logs, " +
    "e.g., val_loss or val_acc",
)
parser.add_argument("data",
                    help="The extracted data " + "(output from this script)")
# print(sys.argv)
args = parser.parse_args(sys.argv[1:])

values = {}


def dict_append(D, key, value):
    if key not in values.keys():
        D[key] = []
    D[key].append(value)


def tokenize(line):
    results = [token for token in line.split(" ") if len(token) > 0]
    return results


def is_final_report(line):
    return "/step" in line


def parse_model_log(f, obj_return):
    target = obj_return + ":"
    with open(f) as fp:
        for line in fp:
            tokens = tokenize(line)
            if tokens[0] == "noise_level":
                noise_level = int(round(float(tokens[1])))
        fp.seek(0)
        # This value will be overwritten, we are looking for the last
        # value for obj_return in the file
        value = "NOTFOUND"
        for line in fp:
            if not is_final_report(line):
                continue
            tokens = tokenize(line)
            for i in range(0, len(tokens) - 1):
                if tokens[i] == target:
                    value = float(tokens[i + 1])
                    break  # 1 level
    if value == "NOTFOUND":
        print("NOTFOUND " + f)
    return (noise_level, value)


for d in os.walk(args.output):
    if "model.log" not in d[2]:
        continue
    f = d[0] + "/model.log"
    (noise, value) = parse_model_log(f, args.obj_return)
    dict_append(values, noise, value)

noises = values.keys()
noises = sorted(noises)

with open(args.data, "w") as fp:
    for noise in noises:
        count = len(values[noise])
        # print("noise=%i count=%i", noise, count)
        # print(values[noise])
        s = sum(values[noise])
        fp.write("%8.4f %8.4f # count=%i\n" % (noise, s / count, count))
