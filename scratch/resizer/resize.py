# RESIZE PY

description = "Resize and/or add noise to CSV data."


def parse_args():
    import argparse

    parser = argparse.ArgumentParser(description=description)
    parser.add_argument(
        "--resize",
        action="store",
        default=1.0,
        help="""
                        Output size scale compared to input size as float.
                        Examples:
                        1.0=same size,
                        0.5=half size,
                        2.0=double size.""",
    )
    parser.add_argument(
        "--noise",
        action="store",
        default=0.0,
        help=""""
                        Noise injection as float.
                        Examples:
                        0.0=no noise
                        0.1=noise +/- 10%""",
    )
    parser.add_argument("input", action="store", help="The input CSV.")
    parser.add_argument("output", action="store", help="The output CSV.")
    args = parser.parse_args()
    argvars = vars(args)
    # print(str(argvars))
    return argvars


def write_data(args, fp, data_out):
    from random import random

    wholes = int(float(args["resize"]))
    noise = float(args["noise"])
    rows, cols = data_out.shape
    for i in range(0, wholes):
        for row in range(0, rows):
            for col in range(0, cols - 1):
                value = data_out[row, col]
                if noise != 0.0:
                    value = value * (1 - noise) + value * (noise * 2) * random()
                fp.write("%f," % value)
            col += 1
            value = data_out[row, col]
            if noise != 0.0:
                value = value * (1 - noise) + value * (noise * 2) * random()
            fp.write("%f" % value)
            fp.write("\n")
    fraction = float(args["resize"]) - wholes
    for row in range(0, int(fraction * rows)):
        for col in range(0, cols - 1):
            value = data_out[row, col]
            if noise != 0.0:
                value = value * (1 - noise) + value * (noise * 2) * random()
            fp.write("%f," % value)
        col += 1
        value = data_out[row, col]
        if noise != 0.0:
            value = value * (1 - noise) + value * (noise * 2) * random()
        fp.write("%f" % value)
        fp.write("\n")


import sys

import numpy as np

args = parse_args()

data_in = np.loadtxt(args["input"], delimiter=",")
data_out = np.copy(data_in)

if args["output"] == "/dev/stdout" or args["output"] == "-":
    fp = sys.stdout
else:
    fp = open(args["output"], "w")

write_data(args, fp, data_out)

if fp is not sys.stdout:
    fp.close()
