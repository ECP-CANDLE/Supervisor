
# OBJ FUNC PY

import os
import sys

assert len(sys.argv) == 3, "\n\n obj_func.py: usage: <set> <output>"

(_, permutation_sets, output) = sys.argv

inputs = eval(permutation_sets)
training, validation = inputs

directory = os.path.dirname(output)

if not os.path.exists(directory):
    os.makedirs(directory)

log = directory + "/" + "run.log"
with open(log, "w") as fp:
    fp.write("training: " + str(training))

with open(output, "w") as fp:
    # fp.write("training: " + str(training) + "\n")
    fp.write("42\n")
