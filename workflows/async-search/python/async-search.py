from mpi4py import MPI
import eqpy
import time
import json
import numpy as np
from skopt import Optimizer
import problem_tc1 as problem

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
    return(";".join([str(i) for i in range(num)]))

def depth(l):
    if isinstance(l, list):
        return 1 + max(depth(item) for item in l)
    else:
        return 0

def create_list_of_json_strings(list_of_lists, super_delim=";"):
    # create string of ; separated jsonified maps
    res = []
    global problem_params
    if (depth(list_of_lists) == 1):
        list_of_lists = [list_of_lists]

    for l in list_of_lists:
        jmap = {}
        for i,p in enumerate(problem_params):
            jmap[p] = l[i]

        jstring = json.dumps(jmap, cls=MyEncoder)
        res.append(jstring)

    return res, (super_delim.join(res))

def run():
    start_time = time.time()
    print('start_time:%1.3f'%start_time)
    comm = MPI.COMM_WORLD   # get MPI communicator object
    size = comm.size        # total number of processes
    rank = comm.rank        # rank of this process
    status = MPI.Status()   # get MPI status object
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
    (init_size, max_evals, num_workers, num_buffer, seed) = eval('{}'.format(initparams))

    space = [spaceDict[key] for key in params]
    print(space)

    parDict = {}
    resultsList = []
    parDict['kappa'] = 1.96
    init_x = []

    opt = Optimizer(space, base_estimator='RF', acq_optimizer='sampling',
                    acq_func='LCB', acq_func_kwargs=parDict, random_state=seed)

    eval_counter = 0
    askedDict = {}
    print("Master starting with {} init_size, {} max_evals, {} num_workers, {} num_buffer".format(init_size,max_evals,num_workers,num_buffer))
    x = opt.ask(n_points=init_size)
    res, resstring = create_list_of_json_strings(x)
    print("Initial design is {}".format(resstring))
    for r,xx in zip(res,x):
        askedDict[r] = xx
    eqpy.OUT_put(resstring)
    currently_out = init_size
    total_out = init_size
    results = []

    group = comm.Get_group()
    # Assumes only one adlb_server
    # num_workers + 1 = num_turbine_workers
    newgroup = group.Excl([num_workers+1])
    #print("ME newgroup size is {}".format(newgroup.size))
    newcomm = comm.Create_group(newgroup,1)
    nrank = newcomm.rank
    #print("ME nrank is {}".format(nrank))

    counter_threshold = 1
    counter = 0
    while eval_counter < max_evals:
        print("\neval_counter = {}".format(eval_counter))
        data = newcomm.recv(source=MPI.ANY_SOURCE, status=status)
        counter = counter + 1
        xstring = data['x']
        x = askedDict[xstring]
        y = data['cost']
        opt.tell(x, y)
        #source = status.Get_source()
        #tag = status.Get_tag()

        elapsed_time = float(time.time() - start_time)
        print('elapsed_time:%1.3f'%elapsed_time)
        if elapsed_time < 5:
            counter_threshold = 10
        else:
            counter_threshold = 1

        results.append(str(data))
        eval_counter = eval_counter + 1
        currently_out = currently_out - 1
        print("currently_out:{}, total_out:{}".format(currently_out,total_out))
        if currently_out < num_workers + num_buffer and total_out < max_evals and counter == counter_threshold:
            n_points = counter
            if n_points + total_out > max_evals:
                n_points = max_evals - total_out
            x = opt.ask(n_points=n_points)
            res, resstring = create_list_of_json_strings(x)
            for r,xx in zip(res,x):
                askedDict[r] = xx

            eqpy.OUT_put(resstring)
            currently_out = currently_out + n_points
            total_out = total_out + n_points
            counter = 0
    print('Search finishing')
    eqpy.OUT_put("DONE")
    eqpy.OUT_put(";".join(results))
