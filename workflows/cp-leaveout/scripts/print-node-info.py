
# EXTRACT NODE INFO PY

import argparse, os, pickle, sys

from Node import Node
from utils import abort

parser = argparse.ArgumentParser(description='Parse all log files')
parser.add_argument('directory',
                    help='The experiment directory (EXPID)')

args = parser.parse_args()

node_pkl = args.directory + "/node-info.pkl"

try: 
    with open(node_pkl, 'rb') as fp:
        data = pickle.load(fp)
except IOError as e:
    abort(e, os.EX_IOERR, "Could not read: " + node_pkl)

# print(data)
for item in data.values():
    print(item.str_table())
