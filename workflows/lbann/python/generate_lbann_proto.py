import sys
import importlib
from mpi4py import MPI
import os, random, math
import runner_utils

import ga_utils

def import_model(framework, model_name):
     module_name = "{}_baseline".format(model_name)
     return importlib.import_module(module_name)

def run(rank,hyper_parameter_map):


    framework = hyper_parameter_map['framework']
    model_name = hyper_parameter_map['model_name']
    pkg = import_model(framework, model_name)
    runner_utils.format_params(hyper_parameter_map)

    # params is python dictionary
    params = pkg.initialize_parameters()
    #print("Rank ", rank, " default params  ", hyper_parameter_map)
    #print("Rank ", rank, " params from master ", hyper_parameter_map)
    for k,v in hyper_parameter_map.items():
        #if not k in params:
        #    raise Exception("Parameter '{}' not found in set of valid arguments".format(k))
        params[k] = v
    
    #write per trainer params to file
    runner_utils.write_params(params, hyper_parameter_map)
    sys.argv = [pkg]
    pkg.run(params)



def init_params(params_file, comm):
    print("Rank ", comm.Get_rank(), " param files ", params_file)
    param_factories = ga_utils.create_parameters(params_file)
    params = [{}]
    for i in range(comm.Get_size() - 1):
        hyper_parameter_map = {}
        for p in param_factories:
            hyper_parameter_map[p.name] = p.randomDraw()
        params.append(hyper_parameter_map)

    return params

def generate_proto(rank, hyper_parameter_map, args):

    exp_dir = args[2]
    instance_dir = "{}/trainer_{}/".format(exp_dir, rank)
    if not os.path.exists(instance_dir):
        os.makedirs(instance_dir)

    model_name = args[3]

    hyper_parameter_map['framework'] = 'lbann'
    hyper_parameter_map['save'] = '{}/output'.format(instance_dir)
    hyper_parameter_map['instance_directory'] = instance_dir
    hyper_parameter_map['model_name'] = model_name
    hyper_parameter_map['experiment_id'] = args[4]
    hyper_parameter_map['run_id'] = rank
    
    # clear sys.argv so that argparse doesn't "cry"
    sys.argv = ['lbann_runner']
    run(rank, hyper_parameter_map)

def init_dirs(outdir):
    if not os.path.exists(outdir):
        os.makedirs(outdir)

def main(args):
    comm = MPI.COMM_WORLD
    rank = comm.Get_rank()
    if rank == 0:
        params = init_params(args[1], comm)
        outdir = args[2]
        init_dirs(outdir)
        comm.scatter(params, root=0)
    else:
        params = comm.scatter(None, root=0)
        generate_proto(rank, params, args)


if __name__ == '__main__':
    main(sys.argv)
