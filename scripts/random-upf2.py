
import logging
import random
import sys

import deap_ga
import ga_utils


def main():
    """ Outline of program """
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
    """
    Use argparse to handle command line
    """
    import argparse
    parser = argparse.ArgumentParser(
        prog="random_upf",
        description="Makes a random UPF file.")
    parser.add_argument("-s", "--seed",
                        action="store",
                        type=int,
                        default=42,
                        help="random seed")
    parser.add_argument("count",
                        help="number of rows to generate")
    parser.add_argument("param_set_file",
                        help="the DEAP parameter set file")
    parser.add_argument("output",
                        help="The output JSON file")
    args = parser.parse_args()
    return args



class UserError(Exception):
    """ Generic user error for the random_upf program. """
    pass


def setup_logger(logger):
    """ Set up the logger for development use """
    logger.setLevel(logging.DEBUG)
    h = logging.StreamHandler(stream=sys.stdout)
    fmtr = logging.Formatter(
            "%(asctime)s %(name)s %(levelname)-5s %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S")
    h.setFormatter(fmtr)
    logger.addHandler(h)
    return logger


def make_upf(logger, args):
    logger.info("SEED: %i" % args.seed)
    random.seed(args.seed)
    ga_params = ga_utils.create_parameters(args.param_set_file)
    for i, param in enumerate(ga_params):
        logger.info("PARAM: %i: %s" % (i+1, repr(param)))
    entries = []
    for i in range(0, args.count):
        entries.append(get_entry(logger, args))



if __name__ == "__main__":
    main()
