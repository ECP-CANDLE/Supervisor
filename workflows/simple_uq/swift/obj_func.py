
# OBJ FUNC PY

import os
import sys

import permute

assert len(sys.argv) == 3, "\n\n obj_func.py: usage: <index> <output>"

(_, index, output) = sys.argv

directory = os.path.dirname(output)

if not os.path.exists(directory):
    os.makedirs(directory)

size = 10
validation = 2

permute.configure(seed=int(index)+10101, size=size, training=size-validation)

training, validation = permute.get_tv()

log = directory + "/" + "run.log"
with open(log, "w") as fp:
    fp.write("training:   " + str(training)   + "\n")
    fp.write("validation: " + str(validation) + "\n\n")

# Funny function
result = float(0.0)
multiplier = float(10*10*10)
for i in range(0,5):
    result = result + training[i]*multiplier
    multiplier /= 10

with open(output, "w") as fp:
    # fp.write("training: " + str(training) + "\n")
    fp.write(str(result)+"\n")
