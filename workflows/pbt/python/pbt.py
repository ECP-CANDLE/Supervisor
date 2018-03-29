import sys
import importlib
from mpi4py import MPI
import os

import ga_utils
import pbt_utils

def init_params(params_file, comm):
    param_factories = ga_utils.create_parameters(params_file)
    params = [{}]
    for i in range(comm.Get_size() - 1):
        hyper_parameter_map = {}
        for p in param_factories:
            hyper_parameter_map[p.name] = p.randomDraw()
        params.append(hyper_parameter_map)

    return params

def run_model(comm, rank, hyper_parameter_map, args):

    exp_dir = args[2]
    instance_dir = "{}/run_{}/".format(exp_dir, rank)
    if not os.path.exists(instance_dir):
        os.makedirs(instance_dir)

    model_name = args[3]

    hyper_parameter_map['framework'] = 'keras'
    hyper_parameter_map['save'] = '{}/output'.format(instance_dir)
    hyper_parameter_map['instance_directory'] = instance_dir
    hyper_parameter_map['model_name'] = model_name
    hyper_parameter_map['experiment_id'] = args[4]
    hyper_parameter_map['run_id'] = rank

    runner = "{}_runner".format(model_name)
    sys.argv = [runner]
    pkg = importlib.import_module(runner)
    weights_dir = "{}/weights".format(exp_dir)
    pbt_callback = pbt_utils.PBTCallback(comm, 0, weights_dir)
    pkg.run(hyper_parameter_map, [pbt_callback])

def init_dirs(outdir):
    if not os.path.exists(outdir):
        os.makedirs(outdir)

    weights_dir = "{}/weights".format(outdir)
    if not os.path.exists(weights_dir):
        os.makedirs(weights_dir)

def main(args):
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()

    if rank == 0:
        params = init_params(args[1], comm)
        outdir = args[2]
        init_dirs(outdir)
        comm.scatter(params, root=0)
        root = pbt_utils.PBTMetaDataStore(comm, outdir)
        root.run()
    else:
        params = comm.scatter(None, root=0)
        run_model(comm, rank, params, args)
        #print("{}: {}".format(rank, params))


if __name__ == '__main__':
    main(sys.argv)
