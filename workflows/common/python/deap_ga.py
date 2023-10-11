"""DEAP GA PY.

EMEWS interface module for DEAP
"""

import csv
import json
import math
import random
import sys
import threading
import time

import log_tools
import eqpy
import ga_utils
import numpy as np
from deap import algorithms, base, creator, tools

# List of ga_utils parameter objects:
ga_params = None

# Last mean value (used if there are no new values):
mean_last = None

generation = 1
logger = log_tools.get_logger(None, "DEAP")


def obj_func(x):
    """Just a stub for the DEAP framework."""
    return 0


def create_list_of_json_strings(list_of_lists, super_delimiter=";"):
    """create string of semicolon-separated jsonified maps Produces something
    like:

    {"batch_size":512,"epochs":51,"activation":"softsign",
     "dense":"2000 1000 1000 500 100 50","optimizer":"adagrad","drop":0.1378,
     "learning_rate":0.0301,"conv":"25 25 25 25 25 1"}
    """
    result = []
    global ga_params
    for L in list_of_lists:
        json_string = create_json_string(L)
        result.append(json_string)
    return super_delimiter.join(result)


def create_json_string(L, indent=None):
    json_dict = {}
    for i, p in enumerate(ga_params):
        json_dict[p.name] = L[i]
    result = json.dumps(json_dict, indent=indent)
    return result


def create_fitnesses(params_string):
    """return equivalent length tuple list.

    :type params_string: str
    """
    params = params_string.split(";")
    # get length
    res = [(i,) for i in range(len(params))]
    return res


def make_floats(results):
    """
    results: String of data from workflow
    return:  List of singleton-tuples, each a float
    This function converts the workflow strings to the DEAP format,
         and replaces any string NaNs in the results with
         the mean of the current generation or
         the mean of the prior   generation.
    """
    global mean_last
    tokens = results.split(";")
    NaNs = []
    values = []
    output = {}
    floats = []
    for i, token in enumerate(tokens):
        if len(token) == 0:
            msg = "received: 0-length token at: %i" % i
            logger.info("ERROR: " + msg)
            logger.info("       tokens: " + str(tokens))
            raise Exception("make_floats(): " + msg)
        elif token.lower() == "nan":
            output[i] = "nan"
            NaNs.append(i)
        else:
            f = float(token)
            output[i] = f
            values.append(f)
    logger.info("RESULTS: values: %i NaNs: %i" % (len(values), len(NaNs)))
    if len(values) > 0:
        mean = sum(values) / len(values)
        mean_last = mean
    else:
        assert mean_last is not None, \
            "all generation=1 results are NaN!"
        mean = mean_last

    for i in NaNs:
        output[i] = mean
    for i in range(0, len(tokens)):
        floats.append((output[i],))
    return floats


def queue_map(_f, pops):
    """Note that _f is not used, but is part of the DEAP framework Formats
    model parameters that look like:

    [[a,b,c,d],[e,f,g,h],...]
    """
    if not pops:
        return []
    global generation
    generation_start = time.time()
    logger.info("GENERATION: %i START: pop: %i" % (generation, len(pops)))
    sys.stdout.flush()
    eqpy.OUT_put(create_list_of_json_strings(pops))
    results = eqpy.IN_get()
    duration = time.time() - generation_start
    logger.info("GENERATION: %i STOP.  duration: %0.3f" %
                (generation, duration))
    sys.stdout.flush()
    generation += 1
    floats = make_floats(results)
    return floats


def make_random_params():
    """Performs initial random draw on each parameter."""
    global ga_params

    draws = []
    for p in ga_params:
        draws.append(p.randomDraw())

    return draws


def parse_init_params(params_file):
    init_params = []
    with open(params_file) as f_in:
        reader = csv.reader(f_in)
        header = next(reader)
        for row in reader:
            init_params.append(dict(zip(header, row)))
    return init_params


def update_init_pop(pop, params_file):
    global ga_params, logger
    logger.info("Reading initial population from {}".format(params_file))
    sys.stdout.flush()
    init_params = parse_init_params(params_file)
    if len(pop) > len(init_params):
        raise ValueError(
            "Not enough initial params to set the population: size of init params < population size"
        )

    for i, indiv in enumerate(pop):
        for j, param in enumerate(ga_params):
            indiv[j] = param.parse(init_params[i][param.name])


# keep as reference for log type
# def mutGaussian_log(x, mu, sigma, mi, mx, indpb):
#     if random.random() < indpb:
#         logx = math.log10(x)
#         logx += random.gauss(mu, sigma)
#         logx = max(mi, min(mx, logx))
#         x = math.pow(10, logx)
#     return x


# Returns a tuple of one individual
def custom_mutate(individual, indpb):
    """Mutates the values in list individual with probability indpb."""

    # Note, if we had some aggregate constraint on the individual
    # (e.g. individual[1] * individual[2] < 10), we could copy
    # individual into a temporary list and mutate though until the
    # constraint was satisfied

    global ga_params
    for i, param in enumerate(ga_params):
        individual[i] = param.mutate(individual[i], mu=0, indpb=indpb)

    return (individual,)


def cxUniform(ind1, ind2, indpb):
    c1, c2 = tools.cxUniform(ind1, ind2, indpb)
    return (c1, c2)


def timestamp(scores):
    return str(time.time())


def run():
    """
    :param num_iter: number of generations
    :param num_pop: size of population
    :param seed: random seed
    :param strategy: one of 'simple', 'mu_plus_lambda'
    :param ga parameters file name: ga parameters file name
           (e.g., "ga_params.json")
    :param param_file: name of file containing initial parameters
    """
    global logger
    start_time = time.time()
    logger.info("OPTIMIZATION START")
    sys.stdout.flush()

    eqpy.OUT_put("Params")
    params = eqpy.IN_get()

    # Evaluate and log the params given by the workflow level:
    (num_iter, num_pop, seed, strategy, off_prop, mut_prob, cx_prob, mut_indpb,
     cx_indpb, tournsize, ga_params_file, param_file) = eval(
         "{}".format(params)
     )  # RW: Add mut_indpb, cx_indpb, tournsize so that they're not hard-coded
    log_params(logger, num_iter, num_pop, seed)

    random.seed(seed)
    global ga_params
    logger.info("params_file: " + ga_params_file)
    ga_params = ga_utils.create_parameters(ga_params_file)

    creator.create("FitnessMin", base.Fitness, weights=(-1.0,))
    creator.create("Individual", list, fitness=creator.FitnessMin)
    toolbox = base.Toolbox()
    toolbox.register("individual", tools.initIterate, creator.Individual,
                     make_random_params)

    toolbox.register("population", tools.initRepeat, list, toolbox.individual)
    toolbox.register("evaluate", obj_func)
    toolbox.register("mate", cxUniform, indpb=cx_indpb)
    toolbox.register("mutate", custom_mutate, indpb=mut_indpb)
    toolbox.register("select", tools.selTournament, tournsize=tournsize)
    toolbox.register("map", queue_map)

    pop = toolbox.population(n=num_pop)
    if param_file != "":
        update_init_pop(pop, param_file)

    hof = tools.HallOfFame(1)
    stats = tools.Statistics(lambda ind: ind.fitness.values)
    stats.register("avg", np.mean)
    stats.register("std", np.std)
    stats.register("min", np.min)
    stats.register("max", np.max)
    stats.register("ts", timestamp)

    # num_iter-1 generations since the initial population is evaluated once first

    if strategy == "simple":
        pop, log = algorithms.eaSimple(
            pop,
            toolbox,
            cxpb=cx_prob,
            mutpb=mut_prob,
            ngen=num_iter - 1,
            stats=stats,
            halloffame=hof,
            verbose=True,
        )
    elif strategy == "mu_plus_lambda":
        mu = num_pop
        lam = round(off_prop * num_pop)
        # Create offspring half the size of population in each generation

        pop, log = algorithms.eaMuPlusLambda(
            pop,
            toolbox,
            mu=mu,
            lambda_=lam,
            cxpb=cx_prob,
            mutpb=mut_prob,
            ngen=num_iter - 1,
            stats=stats,
            halloffame=hof,
            verbose=True,
        )
    else:
        raise NameError("invalid strategy: {}".format(strategy))

    end_time = time.time()

    fitnesses = [str(p.fitness.values[0]) for p in pop]

    logger.info("OPTIMIZATION STOP")
    sys.stdout.flush()

    best_i = -1
    best_fitness = sys.float_info.max
    for i in range(0, len(fitnesses)):
        f = float(fitnesses[i])
        if f < best_fitness:
            best_i = i
            best_fitness = f
    logger.info("BEST: %s == ...\n%s" %
                (best_fitness, create_json_string(pop[best_i], indent=2)))
    sys.stdout.flush()

    # Stop the workflow and post the final outputs
    eqpy.OUT_put("DONE")
    best = create_json_string(pop[best_i], indent=2)
    eqpy.OUT_put(best)
    eqpy.OUT_put(str(best_fitness))
    pop_string = create_list_of_json_strings(pop)
    eqpy.OUT_put(pop_string)
    eqpy.OUT_put(";".join(fitnesses))
    eqpy.OUT_put(str(log))


def log_params(logger, num_iter, num_pop, seed):
    logger.info("HPO PARAMS START")
    logger.info("num_iter: %4i" % num_iter)
    logger.info("num_pop:  %4i" % num_pop)
    logger.info("seed:     %4i" % seed)
    logger.info("HPO PARAMS STOP")
