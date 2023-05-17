# LOG TOOLS

# Standardize some Python logging techniques

import sys

logger = None


def get_logger(logger, name, stream=sys.stdout, milliseconds=False):
    """Set up logging."""
    if logger is not None:
        return logger
    import logging

    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)
    h = logging.StreamHandler(stream=stream)
    if not milliseconds:
        fmtr = logging.Formatter("%(asctime)s %(name)s %(levelname)-5s %(message)s",
                                 datefmt="%Y-%m-%d %H:%M:%S")
    else:
        fmtr = logging.Formatter("%(asctime)s.%(msecs)03d %(name)s %(levelname)-5s %(message)s",
                                 datefmt="%Y-%m-%d %H:%M:%S")

    h.setFormatter(fmtr)
    logger.addHandler(h)
    return logger


# def log(msg):
#     global logger
#     logger.info(msg)

# def log_info(msg):
#     global logger
#     logger = get_logger(logger)
#     logger.info(msg)

# def debug(msg):
#     global logger
#     logger = get_logger(logger)
#     logger.debug(msg)


def timestamp():
    from datetime import datetime

    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")
