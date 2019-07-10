#!/usr/bin/env python

# LIST NODES PY
# Extract just the nodes from the JSON file for human inspection

import argparse, json

parser = argparse.ArgumentParser()
parser.add_argument('plan', type=str, help='Plan data file')
args = parser.parse_args()

try:
    with open(args.plan) as fp:
        J = json.load(fp)
except Exception as e:
    print("could not read JSON in file: %s\n" % args.plan + str(e))
    exit(1)

for k in J.keys():
   print(k)
