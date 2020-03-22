
# PRINT NODE INFO PY

import argparse, os, pickle, sys

from Node import Node
from utils import fail

parser = argparse.ArgumentParser(description='Print Node info stats')
parser.add_argument('directory',
                    help='The experiment directory (EXPID)')

args = parser.parse_args()

node_pkl = args.directory + "/node-info.pkl"

try:
    with open(node_pkl, 'rb') as fp:
        data = pickle.load(fp)
except IOError as e:
    fail(e, os.EX_IOERR, "Could not read: " + node_pkl)

# print(data)
for item in data.values():
    print(item.str_table())

# print(len(data))
