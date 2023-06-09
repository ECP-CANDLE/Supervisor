
# PLOT EXTRACT PY

import argparse
import os
import sys

parser = argparse.ArgumentParser()
parser.add_argument("output",
                    help="The workflow output file " +
                         "(input to this script)")
parser.add_argument("data", help="The extracted data " +
                                 "(output from this script)")
args = parser.parse_args(sys.argv[1:])

# Nested dict where:
#        values[layer][noise] = list(error)
values = {}

# Scan logs, insert into values
with open(args.output) as fp:
    for line in fp:
        tokens = line.split(" ")
        if tokens[0] == "result:":
            layer = int  (tokens[4])
            noise = float(tokens[6])
            value = float(tokens[8])
            if layer not in values.keys():
                values[layer] = {}
            if noise not in values[layer].keys():
                values[layer][noise] = []
            values[layer][noise].append(value)

# Compute averages for values
for layer in values.keys():
    for noise in values[layer].keys():
        L = values[layer][noise]
        n = len(L)
        s = sum(L)
        values[layer][noise] = n / s

import pandas as pd
df = pd.DataFrame(values)

# Sort the columns from left to right (layers):
cols = df.columns.tolist()
cols.sort()
df = df[cols]

# Sort the index (noises)
df.sort_index(inplace=True, ascending=False)
print(str(df))

# Save the data:
df.to_hdf(args.data, key="plot")
print("wrote: " + args.data)
