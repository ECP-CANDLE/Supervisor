
import os

import candle


class Comparator(candle.Benchmark):
    pass


file_path = os.path.dirname(os.path.realpath(__file__))


def initialize_parameters(default_model="cmp_default_model.txt"):
    global file_path
    bmk = Comparator(file_path,
                     default_model,
                     "keras",
                     prog="cmp_baseline",
                     desc="Meta-model to compare two models")
    # Initialize parameters
    gParameters = candle.finalize_parameters(bmk)
    return gParameters


def run(gParameters):
    print("COMPARATOR")
    print(str(gParameters))
    global file_path
    print("file_path: %s" % file_path)


def main():
    gParameters = initialize_parameters()
    run(gParameters)


if __name__ == "__main__":
    main()
