#!/usr/bin/env python

import os, sys

print(sys.argv)

import argparse
parser = argparse.ArgumentParser()
parser.add_argument('output',
                    help='The workflow output file (input to this script)')
parser.add_argument('data',
                    help='The extracted data (output from this script)')
args = parser.parse_args(sys.argv[1:])

values = {}

with open(args.output) as fp:
    for line in fp:
        tokens = line.split(" ")
        if tokens[0] == 'result' and \
           tokens[2] == ":":
            noise = float(tokens[4])
            value = float(tokens[6])
            if noise not in values.keys():
                values[noise] = []
            values[noise].append(value)

noises = values.keys()
noises.sort()

with open(args.data, "w") as fp:
    for noise in noises:
        n = len(values[noise])
        s = sum(values[noise])
        fp.write("%8.4f %8.4f\n" % (noise, s/n))
