import datetime
import json
import math
import sys
import time

import as_problem as problem
import eqpy
import numpy as np
from mpi4py import MPI
from skopt import Optimizer

# list of ga_utils parameter objects
problem_params = None


class MyEncoder(json.JSONEncoder):

    def default(self, obj):
        if isinstance(obj, np.integer):
            return int(obj)
        elif isinstance(obj, np.floating):
            return float(obj)
        elif isinstance(obj, np.ndarray):
            return obj.tolist()
        else:
            return super(MyEncoder, self).default(obj)


def create_points(num):
    return ";".join([str(i) for i in range(num)])


def depth(l):
    if isinstance(l, list):
        return 1 + max(depth(item) for item in l)
    else:
        return 0


def create_list_of_json_strings(list_of_lists, super_delim=";"):
    # create string of ; separated jsonified maps
    res = []
    global problem_params
    if depth(list_of_lists) == 1:
        list_of_lists = [list_of_lists]

    for l in list_of_lists:
        jmap = {}
        for i, p in enumerate(problem_params):
            jmap[p] = l[i]

        jstring = json.dumps(jmap, cls=MyEncoder)
        res.append(jstring)

    return res, (super_delim.join(res))


def run():
    start_time = time.time()
    print("run() start: {}".format(str(datetime.datetime.now())))
    comm = MPI.COMM_WORLD  # get MPI communicator object
    size = comm.size  # total number of processes
    rank = comm.rank  # rank of this process
    status = MPI.Status()  # get MPI status object
    print("ME rank is {}".format(rank))

    instance = problem.Problem()
    spaceDict = instance.space
    params = instance.params
    global problem_params
    problem_params = params
    starting_point = instance.starting_point

    # handshake to ensure working
    eqpy.OUT_put("Params")
    # initial parameter set telling us the number of times to run the loop
    initparams = eqpy.IN_get()
    (init_size, max_evals, num_workers, num_buffer, seed, max_threshold,
     n_jobs) = eval("{}".format(initparams))

    space = [spaceDict[key] for key in params]
    print(space)

    parDict = {}
    resultsList = []
    parDict["kappa"] = 1.96
    # can set to num cores
    parDict["n_jobs"] = n_jobs
    init_x = []

    opt = Optimizer(
        space,
        base_estimator="RF",
        acq_optimizer="sampling",
        acq_func="LCB",
        acq_func_kwargs=parDict,
        random_state=seed,
    )

    eval_counter = 0
    askedDict = {}
    print(
        "Master starting with {} init_size, {} max_evals, {} num_workers, {} num_buffer, {} max_threshold"
        .format(init_size, max_evals, num_workers, num_buffer, max_threshold))
    x = opt.ask(n_points=init_size)
    res, resstring = create_list_of_json_strings(x)
    print("Initial design is {}".format(resstring))
    for r, xx in zip(res, x):
        askedDict[r] = xx
    eqpy.OUT_put(resstring)
    currently_out = init_size
    total_out = init_size
    results = []

    group = comm.Get_group()
    # Assumes only one adlb_server
    # num_workers + 1 = num_turbine_workers
    newgroup = group.Excl([num_workers + 1])
    # print("ME newgroup size is {}".format(newgroup.size))
    newcomm = comm.Create_group(newgroup, 1)
    nrank = newcomm.rank
    # print("ME nrank is {}".format(nrank))

    counter_threshold = 1
    counter = 0
    end_iter_time = 0
    while eval_counter < max_evals:
        start_iter_time = time.time()
        print("\neval_counter = {}".format(eval_counter))
        data = newcomm.recv(source=MPI.ANY_SOURCE, status=status)
        counter = counter + 1
        xstring = data["x"]
        x = askedDict[xstring]
        y = data["cost"]
        if math.isnan(y):
            y = sys.float_info.max
        opt.tell(x, y)
        # source = status.Get_source()
        # tag = status.Get_tag()

        elapsed_time = float(time.time() - start_time)
        print("elapsed_time:%1.3f" % elapsed_time)
        results.append(str(data))
        eval_counter = eval_counter + 1
        currently_out = currently_out - 1

        # if jobs are finishing within 16 seconds of
        # each other, then batch the point production
        if start_iter_time - end_iter_time < 16:
            counter_threshold = max_threshold
            if max_evals - eval_counter < counter_threshold:
                counter_threshold = max_evals - eval_counter
            if counter_threshold > currently_out:
                counter_threshold = currently_out
        else:
            counter_threshold = 1
        print("counter_threshold: {}".format(counter_threshold))

        print("currently_out:{}, total_out:{}".format(currently_out, total_out))
        if (currently_out < num_workers + num_buffer and
                total_out < max_evals and counter >= counter_threshold):
            n_points = counter
            if n_points + total_out > max_evals:
                n_points = max_evals - total_out
            ts = time.time()
            x = opt.ask(n_points=n_points)
            res, resstring = create_list_of_json_strings(x)
            for r, xx in zip(res, x):
                askedDict[r] = xx

            eqpy.OUT_put(resstring)
            print("point production elapsed_time:%1.3f" %
                  float(time.time() - ts))
            currently_out = currently_out + n_points
            total_out = total_out + n_points
            counter = 0

        end_iter_time = start_iter_time

    print("Search finishing")
    eqpy.OUT_put("DONE")
    eqpy.OUT_put(";".join(results))
