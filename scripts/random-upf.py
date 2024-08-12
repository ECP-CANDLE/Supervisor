"""RANDOM UPF See README or --help for usage."""

import logging
import random
import sys

import deap_ga
import ga_utils


def main():
    """Outline of program."""
    logger = logging.getLogger("random_upf")
    setup_logger(logger)
    logger.info("RANDOM UPF")
    args = parse_args()
    try:
        make_upf(logger, args)
    except UserError as e:
        print("random_upf: user error: " + " ".join(e.args))
        exit(1)


def parse_args():
    """Use argparse to handle command line."""
    import argparse
    parser = argparse.ArgumentParser(prog="random_upf",
                                     description="Makes a random UPF file.")
    parser.add_argument("-s",
                        "--seed",
                        action="store",
                        type=int,
                        default=42,
                        help="random seed")
    parser.add_argument("count", type=int, help="number of rows to generate")
    parser.add_argument("param_set_file", help="the DEAP parameter set file")
    parser.add_argument("output", help="The output JSON file")
    args = parser.parse_args()
    return args


class UserError(Exception):
    """Generic user error for the program."""
    pass


def setup_logger(logger):
    """Set up the logger for development use."""
    logger.setLevel(logging.INFO)
    h = logging.StreamHandler(stream=sys.stdout)
    fmtr = logging.Formatter("%(asctime)s %(name)s %(levelname)-5s %(message)s",
                             datefmt="%Y-%m-%d %H:%M:%S")
    h.setFormatter(fmtr)
    logger.addHandler(h)
    return logger


def make_upf(logger, args):
    logger.info("SEED: %i" % args.seed)
    random.seed(args.seed)
    ga_params = ga_utils.create_parameters(args.param_set_file)
    for i, param in enumerate(ga_params):
        logger.info("PARAM: %i: %s" % (i + 1, repr(param)))
    entries = []
    for i in range(0, args.count):
        entry = get_entry(logger, args, ga_params)
        entries.append(entry)
    write_upf(logger, args, entries)


def get_entry(logger, args, params):
    values = deap_ga.draw_random(params)
    # print("choice: " + str(values))
    result = \
        deap_ga.create_json_string_values(params, values, indent=2)
    # print("result: " + result)
    return result


def write_upf(logger, args, entries):
    filename = args.output
    logger.info("write: " + filename)
    with open(filename, "w") as fp:
        for entry in entries:
            fp.write(entry)
            fp.write("\n")


if __name__ == "__main__":
    main()
