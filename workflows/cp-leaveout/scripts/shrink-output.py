
# SHRINK OUTPUT PY
# argv: 2 filenames : tr-*.txt and summary-*.txt
# Called by shrink-output-single.sh
# The tr-*.txt file should have used tr to change CR to NL
# Removes non-printing characters (backspace)
# Reduces the number of training lines in output
# Removes redundant batch size information
# Fixes newline before "Current time" report

import os, re, stat, sys, time
from collections import deque


# Only 1/shrink_factor training lines are copied
shrink_factor = 200
# Number of additional consecutive lines at beginning and end of
# training that are retained
hold_space = 3


def shrink(fp_in, fp_out):
    # Queue to hold extra lines that may be printed at end of run
    Q = deque()
    index = 0
    starts = 0  # Initial hold_space ETAs are immediately printed
    line_previous = ""
    for line in fp_in:
        if len(line) == 1: continue  # Blank line
        line = line.replace("\b", "")
        if "batch:" in line or "Current" in line:
            line = re.sub("- batch: .* 32.0000 -", "", line)
            line = line.replace("Current", "\nCurrent")
            if starts < hold_space:
                fp_out.write(line)
                starts += 1
                continue
            Q.append(line)
            index += 1
            if len(Q) > hold_space:
                line = Q.popleft()
            if index % shrink_factor == 0:
                fp_out.write(line)
        else:
            starts = 0
            while len(Q) > 0:
                fp_out.write(Q.popleft())
            if line == line_previous:
                continue
            fp_out.write(line)
            line_previous = line
    # Done: flush Q:
    while len(Q) > 0:
        fp_out.write(Q.popleft())


# From https://www.codegrepper.com/code-examples/python/python+get+human+readable+file+size
def hsize(size, decimal_places=2):
    if size < 1024:
        return "%4i B" % size
    size /= 1024
    for unit in ["KB","MB","GB","TB"]:
        if size < 1024:
            break
        size /= 1024
    return f"{size:.{decimal_places}f} {unit}"


file_in  = sys.argv[1]
file_out = sys.argv[2]

# Do not process files that have not changed since the last run
# of this script:
if os.path.exists(file_out) and \
   os.path.getmtime(file_in) < os.path.getmtime(file_out):
    print("skipping:  " + file_in)
    exit()

t0 = time.time()
s0 = os.stat(file_in)
z0 = s0[stat.ST_SIZE]
h0 = hsize(z0)
print("shrink:                       %11s                 %s" %
      (h0, file_in))

with open(file_in, "r") as fp_in:
    with open(file_out, "w") as fp_out:
        shrink(fp_in, fp_out)

s1 = os.stat(file_out)
t1 = time.time()
z1 = s1[stat.ST_SIZE]

t = t1 - t0
rate = hsize(z0/t)

print("shrank:  %0.2fs %11s/s  %11s -> %11s  %s" %
      (t, rate, hsize(z0), hsize(z1), file_in))
