#!/usr/bin/env python

# DESCRIBE NODE PY
#

import argparse
import json

parser = argparse.ArgumentParser()
parser.add_argument("plan", type=str, help="Plan data file")
parser.add_argument("node", type=str, help='The node e.g. "1.2.3"')
args = parser.parse_args()

try:
    with open(args.plan) as fp:
        J = json.load(fp)
except Exception as e:
    print("could not read JSON in file: %s\n" % args.plan + str(e))
    exit(1)

for node in J.keys():
    if len(node) == 13:
        # print(node)
        # print(len(J[node]["train"]))
        # print(J[node]["train"])
        for item in J[node]["train"]:
            # print(item)
            # print(item["cell"])
            print(len(item["cell"]))
        print("")
        # exit()
    # print(str(J[args.node]["train"]))
