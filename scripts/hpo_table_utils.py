"""HPO TABLE UTILS PY."""

import logging, sys


def crash(message):
    print("hpo_table: ERROR: " + message)
    exit(1)


def get_logger(logger, name, stream=sys.stdout):
    """Set up logging if necessary If the caller's logger already exists, just
    return it."""
    if logger is not None:
        return logger
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)
    h = logging.StreamHandler(stream=stream)
    fmtr = logging.Formatter("%(asctime)s %(name)s %(levelname)-5s %(message)s",
                             datefmt="%Y-%m-%d %H:%M:%S")
    h.setFormatter(fmtr)
    logger.addHandler(h)
    return logger


def parse_time(d, t):
    """
    d: date as string "YYYY-MM-DD"
    t: time as string "HH:MM:SS"
    returns: a datetime
    """
    import datetime
    v = datetime.datetime.fromisoformat(d + " " + t)
    return v
