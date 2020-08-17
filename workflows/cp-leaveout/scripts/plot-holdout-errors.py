
# PLOT HOLDOUT ERRORS PY
# Plots holdout error data from distill-holdout-errors.pl

import pandas
import matplotlib.pyplot as plt
from pandas.tools.plotting import parallel_coordinates

import argparse
parser = argparse.ArgumentParser(description='Make holdout errors plot')
parser.add_argument('input_file', help='The input errors TSV file')
args = parser.parse_args()

names = ['Stage1','Stage2','Stage3','Stage4', 'Stage5', 'CLASS']
cpdata=pandas.read_csv(args.input_file, sep='\t', header=None, names=names)
parallel_coordinates(cpdata, class_column="CLASS", colormap=plt.get_cmap("Set2"))
