#!/usr/bin/env python3

import random, sys

import numpy as np

import argparse
parser = argparse.ArgumentParser()
parser.add_argument('file',
                    help='The file to modify')
parser.add_argument('rate',
                    help='The fraction to modify')

args = parser.parse_args(sys.argv[1:])

print(args.file, args.rate)

a8 = np.fromfile(args.file, dtype='float64')
print(a8.shape)

rate = float(args.rate)
for i in range(0, a8.shape[0]):
    if random.random() < rate:
        a8[i] = -a8[i]

a8.tofile(args.file)
