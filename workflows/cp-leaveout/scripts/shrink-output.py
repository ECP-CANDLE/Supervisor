
# SHRINK OUTPUT PY
# Receives list of filenames on stdin
# Converts filenames from tr-*.txt to summary-*.txt
# The tr file should have used tr to change carriage return to newline
# Removes non-printing characters (backspace)
# Reduces the number of training lines in output
# Removes redundant batch size information
# Fixes newline before "Current time" report

import os, re, sys
from collections import deque


# Only 1/shrink_factor training lines are copied
shrink_factor = 100
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


file_in  = sys.argv[1]
file_out = sys.argv[2]

# Do not process files that have not changed since the last run
# of this script:
if os.path.exists(file_out) and \
   os.path.getmtime(file_in) < os.path.getmtime(file_out):
    print("skipping:  " + file_in)
    exit()

print("shrinking: " + file_in)
with open(file_in, "r") as fp_in:
    with open(file_out, "w") as fp_out:
        shrink(fp_in, fp_out)
#         files_shrunk += 1

# print("shrink-output.py: shrank %i / %i files." %
#                       (files_shrunk, files_total))
# print("shrink-output.py: OK")
