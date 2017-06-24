import sys
from collections import defaultdict
import json, os

def extractVals(A):
    B = defaultdict(dict)
    A1 = A.split()
    for n, val in zip(A1[0::2], A1[1::2]):
        B[n] = float(val)
    return(B)

def computeStats(swiftArrayAsString):
    A = extractVals(swiftArrayAsString)
    vals = []
    for a in A:
        vals += [A[a]]
    print('%d values, with min=%f, max=%f, avg=%f\n'%(len(vals),min(vals),max(vals),sum(vals)/float(len(vals))))


if (len(sys.argv) < 2):
	print('requires arg=dataFilename')
	sys.exit(1)

dataFilename = sys.argv[1]

try:
    with open(dataFilename, 'r') as the_file:
        data = the_file.read()
except IOError as e:
    print("Could not open: %s" % dataFilename)
    print("PWD is: '%s'" % os.getcwd())

computeStats(data)

