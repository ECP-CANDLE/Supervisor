#!/usr/bin/env python

# LIST NODE SINGLES PY
# Extract the nodes from the JSON file with a single cell line
#         report the node and cell line

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

count = 0

for k in J.keys():
    entry = J[k]
    if "val" not in entry:
        # Root entry
        continue
    val = entry["val"]  # A list
    cells = val[0]["cell"]
    if len(cells) == 1:
        print(k + " " + cells[0])
        count += 1

# print(f"count: {count}")
