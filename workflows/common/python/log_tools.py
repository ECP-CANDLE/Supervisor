
# LOG TOOLS

# Standardize some Python logging techniques

def get_logger(logger, name):
    """ Set up logging """
    if logger is not None:
        return logger
    import logging, sys
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)
    h = logging.StreamHandler(stream=sys.stdout)
    fmtr = logging.Formatter('%(asctime)s %(name)s %(levelname)-9s %(message)s',
                             datefmt='%Y/%m/%d %H:%M:%S')
    h.setFormatter(fmtr)
    logger.addHandler(h)
    return logger
