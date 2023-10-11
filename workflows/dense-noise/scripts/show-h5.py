# SHOW H5 PY

import argparse
import os
import sys

parser = argparse.ArgumentParser()
parser.add_argument("data",
                    help="The extracted data " +
                    "(output from ./plot-extract.py)")
parser.add_argument("key", help="The H5 key to show")

args = parser.parse_args(sys.argv[1:])

import pandas as pd

df = pd.read_hdf(args.data, key=args.key)
print(str(df))

med = df.median().median()
df = -df
mx = df.max().max()

print("max: %r" % mx)
