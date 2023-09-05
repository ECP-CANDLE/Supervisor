# MODEL EXTRACT PY

import argparse
import math
import os
import re
import sys

from pprint import pp

parser = argparse.ArgumentParser()
parser.add_argument("models", help="The list of model.logs")
parser.add_argument("data",
                    help="The extracted data " + "(output from this script)")
args = parser.parse_args(sys.argv[1:])

# Raw data collection
# Dict where values[(layer,noise)] = [errors]
values = {}

# Bucketed data collection
# Nested dict where:
#        data[layer][noise] = [errors]
#    and later
#        data[layer][noise] = mean error
data = {}

# Nested dict where:
#        data[layer][noise] = count = len([errors])
counts = {}


def extract_model_log(model_log):
    # print("extract: " + model_log)
    global values
    # Scan logs, insert into values
    noise = None
    layer = None
    error = None
    with open(model_log, "r") as fp:
        for line in fp:
            tokens = re.split(" +", line)
            if len(tokens) < 2:
                continue
            if tokens[0] == "IMPROVE_RESULT":
                error = float(tokens[1])
                continue
            if len(tokens) < 3:
                continue
            if tokens[1] == "noise":
                noise = float(tokens[2])
            elif tokens[1] == "layer_force":
                layer = int(tokens[2])
            if noise is not None and \
               layer is not None and \
               error is not None:
                break
    if noise is None or \
       layer is None or \
       error is None:
        print("missing data: noise=%r layer=%r error=%r : %s" %
              (noise, layer, error, model_log))
    # print("data: noise=%r layer=%r error=%r : %s" %
    #      (noise, layer, error, model_log))
    if (layer, noise) not in values:
        values[(layer, noise)] = []
    values[(layer, noise)].append(error)


with open(args.models) as fp:
    for line in fp:
        extract_model_log(line.strip())

# List of all noises
noises = []
# List of all layers
layers = []

for kv in values:
    layer, noise = kv
    if layer not in layers:
        layers.append(layer)
    if noise not in noises:
        noises.append(noise)

noises.sort()
layers.sort()

noise_min = noises[0]
noise_max = noises[-1]
noise_range = noise_max - noise_min
buckets = 10
noise_buckets = [
    int(noise_min + i * noise_range / buckets) for i in range(0, buckets)
]

layer_min = layers[0]
layer_max = layers[-1]
layer_range = layer_max - layer_min
buckets = 10
layer_buckets = [
    int(layer_min + i * layer_range / buckets) for i in range(0, buckets)
]

print(str(noise_buckets))
print(str(layer_buckets))

# print(str(data))
for layer in layer_buckets:
    data[layer] = {}
    counts[layer] = {}
    # print(str(data))
    for noise in noise_buckets:
        data[layer][noise] = []
        counts[layer][noise] = 0

# print(str(data))

# print("values: %i" % len(values))


def find_bucket(v, L):
    """Find greatest entry in L that is less than v List L must be sorted May
    return None."""
    assert len(L) > 0
    for i in range(0, len(L)):
        if L[i] > v:
            if i == 0:
                return None
            return L[i - 1]
    return L[i]


count = 0
for kv in values:
    layer, noise = kv
    # print("value: %4i %8.5f -> %3i" % (layer, noise, len(values[kv])))
    layer = find_bucket(layer, layer_buckets)
    noise = find_bucket(noise, noise_buckets)
    # print("data:  %4i %8i -> %3i" % (layer, noise, len(values[kv])))
    data[layer][noise] += values[kv]
    count += len(values[kv])

print("data count: %i" % count)

for layer in layer_buckets:
    for noise in noise_buckets:
        L = data[layer][noise]
        if len(L) == 0:
            data[layer][noise] = math.nan
            continue
        n = len(L)
        print(str(L))
        v = sum(L) / n
        data[layer][noise] = v
        counts[layer][noise] = n

import pandas as pd

df = pd.DataFrame(data)
cf = pd.DataFrame(counts)


def sort_df(df):
    # Sort the columns from left to right (layers):
    cols = df.columns.tolist()
    cols.sort()
    df = df[cols]

    # Sort the index (noises)
    df.sort_index(inplace=True, ascending=False)
    print(str(df))
    return df


df = sort_df(df)
cf = sort_df(cf)

# Save the data:
df.to_hdf(args.data, key="plot")
cf.to_hdf(args.data, key="counts")
print("wrote: " + args.data)
