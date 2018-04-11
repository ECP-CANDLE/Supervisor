import sys
import importlib
from mpi4py import MPI
import os, random, math

import ga_utils
import pbt

from keras import backend as K

class ModelWorker:
    def __init__(self, rank):
        self.rank = rank

    def ready(self, pbt_client, epoch):
        # read every n epochs, n.b. first epoch is 0
        e = epoch + 1
        ready = e % 2 == 0
        if ready:
            pbt_client.log("{}: ready at epoch {}".format(self.rank, epoch))
        return ready

    def pack_data(self, pbt_client, model, metrics):
        """ Packs relevant hyperparameters and selected score metric into a dict to be
            passed to the datastore.

            :param metrics: the metrics in keras callback log
        """
        lr = float(K.get_value(model.optimizer.lr))
        data = {'lr': lr, 'score': metrics['val_loss']}
        data.update(metrics)
        pbt_client.log("{}: putting data".format(self.rank))
        return data

    def update(self, pbt_client, model, data):
        # data: {'acc': 0.87916666666666665, 'loss': 0.38366817765765721, 'rank': 1,
        # 'score': 0.36156702836354576, 'lr': 0.0010000000474974513, 'val_acc': 0.87870370237915607,
        # 'val_loss': 0.36156702836354576}
        old_lr = data['lr']
        lr = old_lr
        draw = random.random()
        if draw <= 0.33:
            lr = old_lr * 0.8
        elif draw <= 0.66:
            lr = old_lr * 1.2
        # else leave as is
        K.set_value(model.optimizer.lr, lr)
        pbt_client.log("{}: updating from rank {}, lr from {} to {}".format(self.rank, data['rank'], old_lr, lr))

def truncation_select(data, score):
    """
     :param data: list of dict containg each ranks' model data as well as
     rank itself.
     :return a tuple of which the first element is the rank of the selected
     item, and the second element is a dictionary containing that rank's metrics,
     and hyperparameters.
    """
    # e.g. data: [{'acc': 0.87916666666666665, 'loss': 0.38366817765765721, 'rank': 1,
    # 'score': 0.36156702836354576, 'lr': 0.0010000000474974513, 'val_acc': 0.87870370237915607,
    # 'val_loss': 0.36156702836354576}, ...]
    items = sorted(data, key=lambda item: item['score'])
    size = len(items)
    if size > 0:
        return items[0]
    return ()
    # quintile = int(round(size / 5.0))
    # if score >= items[-quintile][1]['score']:
    #     # in bottom 20%
    #     idx = random.randint(0, quintile - 1)
    #     return items[idx]
    # else:
    #     return ()

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
    pbt_callback = pbt.PBTCallback(comm, 0, weights_dir, ModelWorker(rank))
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
        log_file = "{}/log.txt".format(outdir)
        root = pbt.PBTMetaDataStore(comm, outdir, truncation_select, log_file)
        root.run()
    else:
        params = comm.scatter(None, root=0)
        run_model(comm, rank, params, args)
        #print("{}: {}".format(rank, params))


if __name__ == '__main__':
    main(sys.argv)
