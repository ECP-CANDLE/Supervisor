
# LOAD PY


from datetime import datetime
import sys

load = 0
D = []

if len(sys.argv) != 3:
    print("usage: load.py START STOP < INPUT")
    exit(1)

def parse(d):
    return datetime.strptime(d, "%Y-%m-%d %H:%M:%S")

def emit(d, load):
    print("%0.2f %03i" % (d.timestamp() - ts_start, load))

start = parse(sys.argv[1])
stop =  parse(sys.argv[2])

ts_start = start.timestamp()

emit(start, load)
    
for line in sys.stdin:
    # line = line.rstrip()
    tokens = line.split()
    date_string = tokens[0] + " " + tokens[1]
    d = parse(date_string)
    # print(date.timestamp())
    if "START" in tokens:
        load += 1
    if "STOP" in tokens:
        load -= 1
    emit(d, load)
    
emit(stop, load)
