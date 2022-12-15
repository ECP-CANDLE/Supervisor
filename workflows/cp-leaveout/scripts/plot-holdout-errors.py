# PLOT HOLDOUT ERRORS PY
# Plots holdout error data from distill-holdout-errors.pl

import argparse

import matplotlib.pyplot as plt
import pandas

# This was removed from Pandas 1.6:
# Cf. https://stackoverflow.com/questions/54473018/where-is-pandas-tools
# from pandas.tools.plotting import parallel_coordinates
from pandas.plotting import parallel_coordinates

parser = argparse.ArgumentParser(description="Make holdout errors plot")
parser.add_argument("stages", type=int, help="Number of stages")
parser.add_argument("file_input", help="The input errors TSV file")
parser.add_argument("file_output", help="The output PNG file")

args = parser.parse_args()

# names = [ 'Stage1','Stage2','Stage3','Stage4', 'Stage5', 'CLASS']

names = []
for i in range(1, args.stages + 1):
    names.append("Stage" + str(i))
names.append("CLASS")

print(str(names))

cpdata = pandas.read_csv(args.file_input, sep="\t", header=None, names=names)
p = parallel_coordinates(cpdata,
                         class_column="CLASS",
                         colormap=plt.get_cmap("Set2"))

# fig = p.gcf()
fig = p.get_figure()
fig.savefig(args.file_output)
