import pandas
import matplotlib.pyplot as plt
from pandas.tools.plotting import parallel_coordinates
 
cpdata=pandas.read_csv('holdout-errors.parallel_plot.tsv',sep='\t', header=None, names=['Stage1','Stage2','Stage3','Stage4', 'Stage5','CLASS'])
parallel_coordinates(cpdata, class_column="CLASS", colormap=plt.get_cmap("Set2"))
