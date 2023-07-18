# MAKE PLOT PY
# Must negate values as the cmp model produces a -abs()
# Centered on median of actual values

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

df = pd.read_hdf(args.data, key="counts")
# df = df
m = df.median().median()
print("median: %0.3f" % m)

cf = pd.read_hdf(args.data, key="counts")

import seaborn as sns

plot = sns.heatmap(df, # cmap="viridis")
                   center=m,
                   cmap=sns.diverging_palette(220, 20, as_cmap=True),
                   annot=cf)

# current_values = plot.gca().get_yticks()
# plot.gca().set_yticklabels(['{:,.0f}'.format(x) for x in current_values])

plot.set_xlabel("layer size")
plot.set_ylabel("noise level (%)")
# plot.collections[0].colorbar.set_label("error (val_loss)")
plot.collections[0].colorbar.set_label("relative error diff (val_loss)")
fig = plot.get_figure()
fig.savefig(args.plot)

print("plotted: " + args.plot)
