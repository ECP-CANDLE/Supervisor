
# SHRINK OUTPUT PY
# Receives list of filenames on stdin
# Converts filenames from out-*.txt to summary-*.txt
# Removes non-printing characters (backspace)
# Reduces the number of training lines in output
# Removes redundant batch size information
# Fixes newline before "Current time" report

import re, sys
from collections import deque


# Only 1/shrink_factor training lines are copied
shrink_factor = 100
# Number of additional consecutive lines at beginning and end of
# training that are retained
hold_space = 5


def shrink(fp_in, fp_out):
    # Queue to hold extra lines that may be printed at end of run
    Q = deque()
    index = 0
    starts = 0  # Initial hold_space ETAs are immediately printed
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
            if len(Q) > hold_space:
                index += 1
                line = Q.popleft()
                if index % shrink_factor == 0:
                    fp_out.write(line)
        else:
            starts = 0
            while len(Q) > 0:
                fp_out.write(Q.popleft())
            fp_out.write(line)
    # Done: flush Q:
    while len(Q) > 0:
        fp_out.write(Q.popleft())


while True:

    line = sys.stdin.readline()

    if len(line) == 0: break     # EOF
    if len(line) == 1: continue  # Blank line

    file_in  = line.strip()
    print("reading: " + file_in)
    file_out = re.sub("/out-", "/summary-", file_in)

    with open(file_in, "r") as fp_in:
        with open(file_out, "w") as fp_out:
            shrink(fp_in, fp_out)

print("shrink-output.py: OK")
