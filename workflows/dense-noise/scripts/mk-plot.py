
# MAKE PLOT PY

import argparse
import os
import sys

parser = argparse.ArgumentParser()
parser.add_argument("data",
                    help="The extracted data " +
                         "(output from ./plot-extract.py)")
parser.add_argument("plot", help="The output plot")
args = parser.parse_args(sys.argv[1:])

import pandas as pd

df = pd.read_hdf(args.data, key="plot")

import seaborn as sns

plot = sns.heatmap(df, # cmap="viridis")
                   cmap=sns.diverging_palette(220, 20, as_cmap=True))
plot.set_xlabel("layer size")
plot.set_ylabel("noise level (%)")
plot.collections[0].colorbar.set_label("error (val_loss)")
fig = plot.get_figure()
fig.savefig(args.plot)
print("plotted: " + args.plot)
